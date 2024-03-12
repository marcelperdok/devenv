#!/usr/bin/env bash

source scripts/log_helpers.sh

#
# Checks if given command is available
# else fails with exit 1
#
assertInstalled () {
    local cmd=$1

    if ! [ -x "$(command -v $cmd)" ]; then
        logFatal "'Command $cmd' is not installed."
        exit 1
    else
        logInfo "Found command '$(command -v $cmd)'"
    fi
}

#
# Checks if given command is available
# else installs given apt package
# Requires sudo
#
ensureAptInstalled () {
    local cmd=$1
    local package=$2

    if ! [ -x "$(command -v $cmd)" ]; then
        logInfo "Command '$cmd' not on system; installing apt package '$package'"
        sudo apt install -y $package
    fi
}

#
# Wrapper to ensure given command is avaible
# Installs provided apt package when not
#
setupAptPackage () {
    local cmd=$1
    local package=$2
    local verbose=${3:-0}

    logHeader3 "Setting up '$cmd'"

    ensureAptInstalled $cmd $package
    assertInstalled $cmd
    
    # Ignore error when command does not support --version
    logDebug "$($cmd --version 2> /dev/null)" $verbose
}