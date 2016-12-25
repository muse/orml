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

source /usr/local/lib/orml/helper.bash

function _help {
    man orml || man ./usr/local/share/man/man1/orml.1 || exit 1
}

function _list {
    case "$1" in
        @hidden) tree -la -CI "${ORML_KEYS##*/}" --prune "$ORML_HIDDEN" ;;
          --|"") tree -la -CI "${ORML_KEYS##*/}" --prune "$ORML_STORE" ;;
              *) tree -la -CI "${ORML_KEYS##*/}" -P "*$1*" --matchdirs --prune "$ORML_STORE" ;;
    esac
    exit 0
}

function _install {
    mkdir -p "$ORML_STORE" "$ORML_HIDDEN"
    if _is_file "$ORML_KEYS"; then
        if ! _confirm "Do you wish to overwrite $ORML_KEYS?"; then
            exit 1
        fi
    fi
    gpg --list-secret-keys | grep ^uid | sed 's/uid *//g' > "$ORML_KEYS"
    exit 0
}

function _export {
    if _is_directory; then
        if _is_true "$ORML_OPTS_ENCRYPT"; then
            _compress | _encrypt > "$1.gpg"
        fi
        _compress > "$1"
        exit 0
    fi
    echo "$ORML_STORE doesn't exist, try doing $ orml install"
    exit 1
}

function _import {
    if _is_directory; then
        if (_is_true "$ORML_OPTS_DECRYPT" || [[ "$1" == *.gpg ]]) &> /dev/null; then
            _decrypt < "$1" | _decompress
        fi
        _decompress < "$1"
        exit 0
    fi
    echo "$ORML_STORE doesn't exist, try doing $ orml install"
    exit 1
}

function _insert {
    if ! _is_path "$1"; then
        _accept "$2" <&0
        mkdir -p "$ORML_STORE/${1%/*}"
        {
            _encrypt < "$IN" || _encrypt <<< "$IN"
        } > "$ORML_STORE/${1%/*}/${1##*/}" 2> /dev/null
        exit 0
    fi
    echo "$ORML_STORE/$1 already exists"
    exit 1
}

function _select {
    if _is_hidden "$1"; then
        _decrypt <<< "$ORML_HIDDEN/$(_hash "$1")"
        exit 0
    elif _is_file "$1"; then
        _decrypt <<< "$ORML_STORE/$1"
        exit 0
    fi
    echo "$1 doesn't exist"
    exit 1
}

function _hide {
    if _is_file "$1"; then
        if _is_hidden "$1"; then
            echo "$1 is already hidden"
            exit 1
        fi
        mv "$ORML_STORE/$1" "$ORML_HIDDEN/$(_hash "$1")"
        exit 0
    fi
    echo "$1 doesn't exist as a file"
    exit 1
}

function _unhide {
    if _is_hidden "$1"; then
        if _is_file "$1"; then
            echo "$1 is already a file"
            exit 1
        fi
        mv "$ORML_HIDDEN/$(_hash "$1")" "$ORML_STORE/$1"
        exit 0
    fi
    echo "$1 doesn't exist as a hidden file"
    exit 1
}

function _drop {
    if _is_file "$1"; then
        rm "$ORML_STORE/$1"
    elif _is_directory "$1"; then
        rm -r "$ORML_STORE/$1"
    elif _is_hidden "$1"; then
        rm "$ORML_HIDDEN/$(_hash "$1")"
    else
        echo "$1 doesn't exist"
        exit 1
    fi
    exit 0
}
