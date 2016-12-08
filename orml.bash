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

source lib/command.bash

ORML_VERSION="0.1"
ORML_NAME="$0"
ORML_COMMAND="$1"
ORML_LONG="as:,hidden,force,clipboard,null,encrypt,decrypt"
ORML_SHORT=":"
ORML_ALLOC="${ORML_ALLOC:-$HOME}"
ORML_STORE="${ORML_STORE:-$ORML_ALLOC/.orml}"
ORML_KEYS="${ORML_KEYS:-$ORML_STORE/keys}"
ORML_HIDDEN="${ORML_HIDDEN:-$ORML_STORE/.hidden}"

ORML_OPTS_AS="$(head -1 "$ORML_KEYS" 2> /dev/null)"
ORML_OPTS_NULL=false
ORML_OPTS_ENCRYPT=false
ORML_OPTS_DECRYPT=false
ORML_OPTS_CLIPBOARD=false
ORML_OPTS_HIDDEN=false

export GPG_TTY=$(tty 2> /dev/null)

function _argv {
    # XXX: Validate that OSX users have GNU getopt and not BSD
    eval set -- $(getopt \
                -o "$ORML_SHORT" \
                -l "$ORML_LONG" \
                -n "$ORML_NAME" \
                -- "$@")
    while :; do
        case $1 in
            --as)
                ORML_OPTS_AS="$2"
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
    # I don't like this right now, the only reason this is done is to keep the
    # second case outside of a function scope. If it were to be IN a function
    # scope we would lose access to the variables created in this case.
    #
    # XXX: Look for a different way to do this.
    #   #: 2016-11-17 22:31
    #   #: I've tried to pipe it and use `xargs @cmd <&0` to call the command,
    #   #: this however still resulted in a loss of the variables.
    #   #:
    #   #: Another attempt was to pass `env` with it, this however required a
    #   #: lot of work and resulted in a overall worse result.
    #   #:
    #   #: I might consider removing the function at all, and keeping everything
    #   #: in the process scope. I do really like having functions to keep
    #   #: things separated.
    #   #:
    #   #: 2016-11-23 20:13
    #   #: This is still bothering me, but now mostly because ORML_ARGV is
    #   #: annoying to access a lot of times, which currently is happening.
    #   #:
    #   #: I've come to terms with setting the variable here, this is probably
    #   #: the best way to extract an argument array from a function, the variable
    #   #: has to be set somewhere.
    #   #:
    #   #: The next step however is to actually pass this variable to the
    #   #: commands so we can use the arguments ($n) instead of the
    #   #: variable (OMRL_ARGV[n]).
    #   #:
    #   #: 2016-12-08 22:00
    #   #: I take it back, THIS is probably the best way to export an array.
    #   #: we reassign the function arguments to the ORML_ARGV array explictly.
    #   #: Snapshot:
    #   #: M=0
    #   #: for N in "$@"
    #   #: do
    #   #:   ORML_ARGV[$M]="$N"
    #   #:   M=$(($M + 1))
    #   #: done
    M=0 && for N in "$@"; do ORML_ARGV[$M]="$N" && M=$(($M + 1)); done
}

case "$ORML_COMMAND" in
    import|export|list|install|insert|select|hide|unhide|drop)
        _argv "$@" && "_${ORML_COMMAND}" "${ORML_ARGV[@]}" <&0 ;;
    test)
        _argv "$@" && ORML_ALLOC=/tmp _test ;;
    *)
        echo "[$ORML_COMMAND] isn't a valid command"
        exit 1 ;;
esac
