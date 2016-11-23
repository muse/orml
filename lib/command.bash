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

source lib/helper.bash

function _test {
    ./test/*.test.bash
}

function _list {
    tree -Cal -I "keys" --prune "$ORML_STORE"
}

function _install {
    # XXX: Might look to dependency check here as well and perhaps when we use a ORML_SYS variable.
    mkdir -p "$ORML_STORE" "$ORML_TRASH" "$ORML_HIDDEN"
    if _is_file "$ORML_KEYS"; then
        if ! _confirm "Do you wish to overwrite $ORML_KEYS?"; then
            exit 1
        fi
    fi
    gpg --list-secret-keys | grep ^uid | sed 's/uid *//g' > "$ORML_KEYS"
    exit 0
}

function _insert {
    REPLY=${ORML_ARGV[1]:-$(_prompt "text, password or file: ")}
    ! _is_file "${ORML_ARGV[0]}"
    case $? in
        0)
            mkdir -p "$ORML_STORE/${ORML_ARGV[0]%/*}"
            {
                [[ -f "$REPLY" ]] && {
                    _cipher "encrypt" < "$REPLY"
                    exit 0
                } || {
                    _cipher "encrypt" <<< "$REPLY"
                    exit 1
                }
            } > "$ORML_STORE/${ORML_ARGV[0]%/*}/${ORML_ARGV[0]##*/}" ;;
        1)
            echo "$ORML_STORE/${ORML_ARGV[0]} already exists, use $ orml edit"
            exit 1 ;;
    esac
}

function _select {
    for ORML_PATH in "${ORML_ARGV[@]}"; do
        _is_hidden "$ORML_PATH"
        case $? in
            0)  _cipher "decrypt" <<< "$ORML_HIDDEN/$(_hash "$ORML_PATH")"
                exit 0 ;;
            1)
                _is_file "$ORML_PATH"
                case $? in
                    0)
                        _cipher "decrypt" <<< "$ORML_STORE/$ORML_PATH"
                        exit 0 ;;
                    1)
                        echo "$ORML_PATH doesn't exist"
                        exit 1 ;;
                esac ;;
        esac
    done
}

function _hide {
    _is_file "${ORML_ARGV[0]}"
    case $? in
        0)
            mv "$ORML_STORE/${ORML_ARGV[0]}" "$ORML_HIDDEN/$(_hash "${ORML_ARGV[0]}")"
            exit 0 ;;
        1)
            echo "${ORML_ARGV[0]} doesn't exist as a file"
            exit 1 ;;
    esac
}

function _unhide {
    _is_hidden "${ORML_ARGV[0]}"
    case $? in
        0)
            mv "$ORML_HIDDEN/$(_hash "${ORML_ARGV[0]}")" "$ORML_STORE/${ORML_ARGV[0]}"
            exit 0 ;;
        1)
            echo "${ORML_ARGV[0]} doesn't exist as a hidden file"
            exit 1 ;;
    esac
}

function _drop {
    _is_file "${ORML_ARGV[0]}"
    case $? in
        0)
            rm "$ORML_STORE/${ORML_ARGV[0]}"
            exit 0 ;;
        1)
            _is_directory "${ORML_ARGV[0]}"
            case $? in
                0)
                    rm -r "$ORML_STORE/${ORML_ARGV[0]}"
                    exit 0 ;;
                1)
                    _is_hidden "${ORML_ARGV[0]}"
                    case $? in
                        0)
                            rm "$ORML_HIDDEN/$(_hash "${ORML_ARGV[0]}")"
                            exit 0 ;;
                        1)
                            echo "${ORML_ARGV[0]} doesn't exist as a path"
                            exit 1 ;;
                    esac ;;
            esac ;;
    esac
}
