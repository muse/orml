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

set -uo pipefail

declare -r store=/tmp/.orml:$$
declare -r keyfile="${1:-somebody.key}"
declare -r passphrase=insecure
declare -r key=some@bo.dy

function :assert {
    ((code == 0))
    :write $? "$cmd"
}

function :refute {
    ((code != 0))
    :write $? "$cmd"
}

function :write {
    case $1 in
        0) echo >&1 "$(tput setaf 2){$$, $code} ✓: orml ${*:2} ${stdin:+"<<< $stdin"} $(tput sgr0) " ;;
        *) echo >&2 "$(tput setaf 1){$$, $code} ✘: orml ${*:2} ${stdin:+"<<< $stdin"} [$error]$(tput sgr0)" ;;
    esac
}

function :test {
    test -s /dev/stdin
    case $? in
        0) stdin="$(cat <&0)" ;;
        *) stdin="" ;;
    esac
    cmd="$*"
    error=$(ORML_ALLOC="/tmp" ORML_STORE="$store" orml "$@" 2>&1 >/dev/null <<< "${stdin:-}")
    code=$?
}

function :init {
    hash orml &> /dev/null
    case $? in
        0) gpg --batch --gen-key "$keyfile" ;;
        *) echo >&2 "orml isn't installed or permitted to run"
           exit 1 ;;
    esac
}

function :clean {
    local fingerprint=
    fingerprint=$(gpg -Kq --with-colons --fingerprint "$key")
    fingerprint=($(sed -n 's/^fpr:::::::::\([[:alnum:]]*\):/\1/p' <<< "$fingerprint"))
    case ${#fingerprint[@]} in
        0) echo >&2 "Couldn't find any fingerprint matching: $key" ;;
        1) rm -rvf "$store"
           gpg --delete-secret-key --batch --yes "${fingerprint[0]}"
           gpg --delete-key        --batch --yes "${fingerprint[0]}" ;;
        *) echo >&2 "Found more than one fingerprint matching: $key" ;;
    esac
}

:init
    # Install, version, help & list
    :test install "$key"
    :assert
    :test version
    :assert
    :test help
    :assert
    :test list
    :assert

    # Insert
    :test insert foo/bar "foolish"
    :assert
    :test insert --secret 64 foo/super-secret
    :assert
    :test insert foo/rab <<< "hsiloof"
    :assert
    :test insert
    :refute

    # Select
    :test select --passphrase "$passphrase" foo/bar
    :assert
    :test select --passphrase "$passphrase" foo/super-secret
    :assert
    :test select --passphrase "$passphrase" foo/rab
    :assert
    :test select
    :refute

    # Move
    :test move foo/bar foo/who
    :assert
    :test move foo/bar foo/she
    :refute
    :test move foo/who foo/rab <<< n
    :refute
    :test move foo/who foo/bar
    :assert
    :test move foo/bar
    :refute
    :test move
    :refute

    # Export
    :test export "$store/snapshot"
    :assert
    :test export --encrypt "$store/snapshot-safe"
    :assert
    :test export
    :refute

    # Import
    :test import "$store/snapshot"
    :assert
    :test import --decrypt --passphrase "$passphrase" "$store/snapshot-safe"
    :assert
    :test import
    :refute

    # Hide
    :test hide foo/bar
    :assert
    :test hide foo/rab
    :assert
    :test hide
    :refute

    # Unhide
    :test unhide foo/bar
    :assert
    :test unhide foo/rab
    :assert
    :test unhide
    :refute

    # Drop
    :test drop foo/bar <<< y
    :assert
    :test drop foo/rab <<< n
    :refute
    :test drop foo <<< y
    :assert
    :test drop
    :refute
:clean
