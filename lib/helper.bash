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
    if [[ "$ORML_OPTS_PASSWORD" ]]; then
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

function _cipher {
    if _is_file "$ORML_KEYS"; then
        ORML_OPTS_AS=${ORML_OPTS_AS:-$(head -1 "$ORML_KEYS")}
        case "$1" in
            encrypt)
                gpg --encrypt -u "$ORML_OPTS_AS" -r "$ORML_OPTS_AS"
                return 0
                ;;
            decrypt)
                # XXX: We can't decrypt multiple files right now,
                #   #: --decrypt-files throws a error and I haven't been
                #   #: able to find the solution.
                xargs gpg --decrypt --batch --quiet --yes
                return 0
                ;;
        esac
    fi
    echo "$ORML_KEYS doesn't exist, try doing $ $ORML_NAME install" 1>2
    exit 1
}
