#!/usr/bin/env bash
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function _version {
    echo "$ORML_VERSION"
    exit $?
}

function _help {
    man orml || exit 1
    exit $?
}

function _install {
    mkdir -p "$ORML_STORE" "$ORML_HIDDEN"
    if _is_file "$ORML_KEYS"; then
        if ! _confirm "Do you wish to overwrite $ORML_KEYS?"; then
            exit 1
        fi
    fi
    case "$1" in
        "") gpg -Kq ;;
         *) gpg -Kq "$1" ;;
    esac | grep ^uid | sed 's/uid *//g' > "$ORML_KEYS"
    exit $?
}

function _list {
    case "$1" in
        @hidden) tree -la -CI "${ORML_KEYS##*/}" --prune "$ORML_HIDDEN" ;;
          --|"") tree -la -CI "${ORML_KEYS##*/}" --prune "$ORML_STORE" ;;
              *) tree -la -CI "${ORML_KEYS##*/}" -P "*$1*" --matchdirs --prune "$ORML_STORE" ;;
    esac
    exit $?
}

function _move {
    if _is_path "$1"; then
        if _is_path "$2"; then
            if ! _confirm "Overwrite $2?"; then
                exit 1
            fi
        fi
        mv "$ORML_STORE/$1" "$ORML_STORE/$2"
        exit $?

    fi
    echo >&2 "$1 doesn't exist"
    exit 1
}

function _export {
    if _is_true "$ORML_OPTS_ENCRYPT"; then
        _compress | _encrypt > "$1"
        exit $?
    fi
    _compress > "$1"
    exit $?
}

function _import {
    if (_is_true "$ORML_OPTS_DECRYPT" || [[ "$1" == *.gpg ]]); then
        _decrypt <<< "$1" | _decompress
        exit $?
    fi
    _decompress < "$1"
    exit $?
}

function _insert {
    if ! _is_path "$1"; then
        _accept "$2" <&0
        mkdir -p "$ORML_STORE/${1%/*}"
        (_encrypt < "$IN" || _encrypt <<< "$IN") \
               1> "$ORML_STORE/${1%/*}/${1##*/}" \
               2> /dev/null
        exit $?
    fi
    echo >&2 "$ORML_STORE/$1 already exists"
    exit 1
}

function _select {
    if _is_hidden "$1"; then
        _decrypt <<< "$ORML_HIDDEN/$(_hash "$1")"
    elif _is_file "$1"; then
        _decrypt <<< "$ORML_STORE/$1"
    else
        echo >&2 "$1 doesn't exist"
        exit 1
    fi
    exit $?
}

function _hide {
    if _is_file "$1"; then
        if _is_hidden "$1"; then
            echo >&2 "$1 is already hidden"
            exit 1
        fi
        mv "$ORML_STORE/$1" "$ORML_HIDDEN/$(_hash "$1")"
        exit $?
    fi
    echo >&2 "$1 doesn't exist"
    exit 1
}

function _unhide {
    if _is_hidden "$1"; then
        if _is_file "$1"; then
            echo >&2 "$1 is already a unhidden"
            exit 1
        fi
        mv "$ORML_HIDDEN/$(_hash "$1")" "$ORML_STORE/$1"
        exit $?
    fi
    echo >&2 "$1 isn't hidden"
    exit 1
}

function _drop {
    if _is_directory "$1"; then
        _confirm "$1?" && rm -rf "${ORML_STORE:?}/$1/"
    elif _is_hidden "$1"; then
        _confirm "$1?" && rm "$ORML_HIDDEN/$(_hash "$1")"
    elif _is_file "$1"; then
        _confirm "$1?" && rm "$ORML_STORE/$1"
    else
        echo >&2 "$1 doesn't exist"
        exit 1
    fi
    exit $?
}
