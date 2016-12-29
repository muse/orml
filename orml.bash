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

source /usr/local/lib/orml/command.bash

ORML_VERSION="0.4"
ORML_NAME="$0"
ORML_COMMAND="${1:-list}"
ORML_LONG="as:,secret:,hidden,password,clipboard,null,encrypt,decrypt"
ORML_SHORT=":"
ORML_ALLOC="${ORML_ALLOC:-$HOME}"
ORML_STORE="${ORML_STORE:-$ORML_ALLOC/.orml}"
ORML_KEYS="${ORML_KEYS:-$ORML_STORE/keys}"
ORML_HIDDEN="${ORML_HIDDEN:-$ORML_STORE/.hidden}"

ORML_OPTS_AS="$(head -1 "$ORML_KEYS" 2> /dev/null)"
ORML_OPTS_SECRET=-1
ORML_OPTS_NULL=false
ORML_OPTS_ENCRYPT=false
ORML_OPTS_DECRYPT=false
ORML_OPTS_CLIPBOARD=false
ORML_OPTS_HIDDEN=false

export GPG_TTY=$(tty 2> /dev/null)

function _argv {
    eval set -- $(getopt \
                -o "$ORML_SHORT" \
                -l "$ORML_LONG" \
                -n "$ORML_NAME" \
                -- "$@")
    while :; do
        case "$1" in
            --as)
                ORML_OPTS_AS="$2"
                shift 2 ;;
            --secret)
                ORML_OPTS_SECRET="$2"
                shift 2 ;;
            --encrypt)
                ORML_OPTS_ENCRYPT=true
                shift 1 ;;
            --decrypt)
                ORML_OPTS_DECRYPT=true
                shift 1 ;;
            --hidden)
                ORML_OPTS_HIDDEN=true
                shift 1 ;;
            --password)
                ORML_OPTS_PASSWORD=true
                shift 1 ;;
            --clipboard)
                ORML_OPTS_CLIPBOARD=true
                shift 1 ;;
            --null)
                ORML_OPTS_NULL=true
                shift 1 ;;
            --)
                # We shift twice here because we save the command at the top of
                # the script, this will remove the command together with --.
                shift 2
                break ;;
            *)
                echo "You've come where no man was to come"
                exit 1 ;;
        esac
    done
    local M=0 N= && for N in "$@"; do ORML_ARGV[$M]="$N" && M=$(($M + 1)); done
}

case "$ORML_COMMAND" in
    version|help|import|export|list|install|insert|select|hide|unhide|drop)
        _argv "$@" && "_${ORML_COMMAND}" "${ORML_ARGV[@]}" <&0 ;;
    *)
        echo "[$ORML_COMMAND] isn't a valid command"
        exit 1 ;;
esac
