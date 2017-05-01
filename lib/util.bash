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

function _is_hook {
    if [[ -f "$ORML_HOOKS/$1" ]]; then
        return 0
    fi; return 1
}

function _confirm {
    if _is_true "$ORML_OPTS_FORCE"; then
        return 0
    else
        read -rp "$1 [y/N]"
        if [[ "$REPLY" == [yY]* ]]; then
            return 0
        fi; return 1
    fi
}

function _prompt {
    if _is_true "$ORML_OPTS_PASSWORD"; then
        read -rsp "$1"
    else
        read -rp "$1"
    fi
    echo "$REPLY"
    return $?
}

function _accept {
    if [[ $ORML_OPTS_SECRET -gt 0 ]]; then
        IN=$(_secret "$ORML_OPTS_SECRET")
    elif [[ -z "$1" ]]; then
        IN=$(_prompt "text, password (visible without --password) or file: ")
    elif [[ $1 == "-" ]]; then
        IN=$(cat)
    else
        IN="$1"
    fi
    return $?
}

function _hash {
    cut '-d ' '-f1' < <(shasum <<< "$1")
    return $?
}

function _compress {
    (cd "$ORML_STORE" && tar -czf - .)
    return $?
}

function _decompress {
    (cd "$ORML_STORE" && tar -xzpf -)
    return $?
}

function _secret {
    LC_CTYPE=C tr -dc "!'\#$%&()*+,-./[0-9]:;<=>?@[A-Z][\]^_\`[a-z]{|" < /dev/urandom | head -c "$1"
    return $?
}

function _clip {
    case $(command uname -s) in
         Linux) xclip -selection CLIPBOARD ;;
        Darwin) pbcopy ;;
    esac
    return $?
}

function _encrypt {
    gpg --encrypt -u "$ORML_OPTS_AS" -r "$ORML_OPTS_AS"
    return $?
}

function _decrypt {
    case ${#ORML_OPTS_PASSPHRASE} in
        0) gpg --batch --quiet --decrypt "$(cat)" ;;
        *) gpg --batch --quiet --passphrase "$ORML_OPTS_PASSPHRASE" --decrypt "$(cat)" ;;
    esac | case "$ORML_COMMAND" in
        import) cat ;;
             *) {
                    read -r value
                    stdout=/dev/fd/1
                    if _is_true "$ORML_OPTS_NULL"; then
                        stdout=/dev/null
                    fi
                    if _is_true "$ORML_OPTS_CLIPBOARD"; then
                        printf "%s" "$value" | _clip
                    fi
                    printf "%s" "$value" > "$stdout"
                } ;;
    esac
    return $?
}
