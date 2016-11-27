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

function _is_true {
    if [[ "$1" = true ]]; then
        return 0
    fi; return 1
}

function _is_file {
    if [[ -f "$ORML_STORE/${1#${ORML_STORE}}" ]]; then
        return 0
    fi; return 1
}

function _is_directory {
    if [[ -d "$ORML_STORE/${1#${ORML_STORE}}" ]]; then
        return 0
    fi; return 1
}

function _is_path {
    if [[ -e "$ORML_STORE/${1#${ORML_STORE}}" ]]; then
        return 0
    fi; return 1
}

function _is_hidden {
    if [[ -f "$ORML_HIDDEN/$(_hash "$1")" ]]; then
        return 0
    fi; return 1
}

function _confirm {
    read -rp "$1 [y/N]"
    if [[ "$REPLY" == [yY]* ]]; then
        return 0
    fi; return 1
}

function _prompt {
    if _is_true "$ORML_OPTS_PASSWORD"; then
        read -rsp "$1"
    else
        read -rp "$1"
    fi
    echo "$REPLY"
    return 0
}

function _hash {
    if [[ -n "$1" ]]; then
        cut '-d ' '-f1' < <(shasum <<< "$1")
    fi
}

function _compress () (
    cd "$ORML_STORE" && tar -cf - .
)

function _decompress () (
    cd "$ORML_STORE" && tar -xpf -
)

function _encrypt {
    _is_file "$ORML_KEYS"
    case $? in
        0)
            gpg --encrypt -u "$ORML_OPTS_AS" -r "$ORML_OPTS_AS"
            return 0 ;;
        1)
            echo "$ORML_KEYS doesn't exist, try doing $ orml install"
            return 1 ;;
    esac
}

function _decrypt {
    _is_file "$ORML_KEYS"
    case $? in
        0)
            xargs gpg --decrypt --batch --quiet --yes
            return 0 ;;
        1)
            echo "$ORML_KEYS doesn't exist, try doing $ orml install"
            return 1 ;;
    esac
}
