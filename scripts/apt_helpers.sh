#!/usr/bin/env bash

#
# Checks if given command is available, else installs command using given apt package
# Requires sudo
#
aptEnsureCommandIsAvailable () {
    local cmd=$1
    local package=$2

    if ! [ -x "$(command -v $cmd)" ]; then
        logInfo "Command '$cmd' not on system; installing apt package '$package'"
        sudo apt install -y $package
    fi
    
    assertCommandIsAvailable $cmd
}

#
# Checks if given package is installed, else installs the missing package 
# Requires sudo
#
aptEnsurePackageIsInstalled () {
    local package=$1
    local installed=$(aptPackageIsInstalled "$package")

    if [ $installed == 0 ]; then
        logInfo "Package '$package' not on system; installing apt package '$package'"
        sudo apt install -y $package
    else
        logInfo "Package '$package' already on the system"
    fi
}

#
# Wrapper to ensure given command is available
# Installs provided apt package when not
#
aptCommandSetup () {
    local cmd=$1
    local package=$2
    local verbose=${3:-0}

    logHeader3 "Setting up '$cmd' using apt package '$package'"

    aptEnsureCommandIsAvailable $cmd $package
    
    # Ignore error when command does not support --version
    logDebug "$($cmd --version 2> /dev/null)$($cmd version 2> /dev/null)" $verbose
}

#
# Checks if given apt package is installed on the system
#
aptPackageIsInstalled () {
    local package=$1

    apt list --installed 2> /dev/null | grep -q "^$package"

    if [ $? == 0 ]; then
        echo 1
    else
        echo 0
    fi
}

#
# Wrapper to ensure given package is available
#
aptPackageSetup () {
    local package=$1

    logHeader3 "Setting up apt package '$package'"

    aptEnsurePackageIsInstalled $package
}

#
# Prepares apt
# Requires sudo
#
aptPrepare () {
    logHeader2 "Preparing apt package manager"

    logHeader3 "Updating apt"
    sudo apt update -y
    
    logHeader3 "Upgrading apt"
    sudo apt upgrade -y

    logHeader3 "Removing unused apt packages"
    sudo apt autoremove -y
}
