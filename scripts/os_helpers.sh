#!/usr/bin/env bash

#
# Checks if a command is available on the system
#
commandIsAvailable () {
    local cmd=$1

    if [ -x "$(command -v $cmd)" ]; then
        echo 1
    else
        echo 0
    fi
}

#
# Asserts if given command is available
#
assertCommandIsAvailable () {
    local cmd=$1
    local available=$(commandIsAvailable "$cmd")

    if [ $available == 1 ]; then
        logInfo "Found command '$(command -v $cmd)'"
    else
        logFatal "'Command $cmd' is not available"
        exit 1
    fi
}

#
# RFC 3339 date time with seconds
dateRfc () { date --rfc-3339=seconds; }

#
# Silent popd wrapper
#
popd () { command popd "$@" > /dev/null; }

#
# Silent pushd wrapper
#
pushd () { command pushd "$@" > /dev/null; }

#
# Sync system clock
# Requires sudo
#
syncClock () { sudo hwclock -s; }

#
# Gets the default shell for the active user
#
defaultShell () { getent passwd "$USER" | awk -F: '{ print $7 }' | awk -F'/' '{print tolower($NF)}'; }

#
# Checks if bash is the default shell for the active user
#
defaultShellIsBash () {
    local shell=$(defaultShell)

    if [ "$shell" == "bash" ]; then
        echo 1
    else
        echo 0
    fi
}

#
# Checks if zsh is the default shell for the active user
#
defaultShellIsZsh () {
    local shell=$(defaultShell)

    if [ "$shell" == "zsh" ]; then
        echo 1
    else
        echo 0
    fi
}

ensureDefaultShellIsZsh () {
    result="$(defaultShellIsZsh)"

    if [ $result == 0 ]; then
        logInfo "Switching default shell to zsh"
        chsh -s $(which zsh)
    else
        logInfo "Default shell is already set to zsh"
    fi
}