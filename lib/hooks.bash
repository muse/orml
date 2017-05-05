#!/usr/bin/env bash
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

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

function _hook:run {
    bash "$ORML_HOOKS/$1" "${ORML_ARGV[@]}" 2> /dev/null
}

function _hook:add {
    if ! _is_hook "$1"; then
        echo "$2" > "$ORML_HOOKS/$1"
        exit $?
    fi
    echo >&2 "$1 is already a hook"
    exit 1
}

function _hook:drop {
    if _is_hook "$1"; then
        _confirm "$1?" && rm "$ORML_HOOKS/$1"
        exit $?
    fi
    echo >&2 "$1 isn't a hook"
    exit 1
}

function _hook:disable {
    if _is_hook "$1"; then
        mv "$ORML_HOOKS/$1" "$ORML_HOOKS/%$1"
        exit $?
    fi
    echo >&2 "$1 isn't enabled or doesn't exist"
    exit 1
}

function _hook:enable {
    if _is_hook "%$1"; then
        mv "$ORML_HOOKS/%$1" "$ORML_HOOKS/$1"
        exit $?
    fi
    echo >&2 "$1 isn't disabled or doesn't exist"
    exit 1
}
