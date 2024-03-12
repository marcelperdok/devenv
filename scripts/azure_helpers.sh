#!/usr/bin/env bash

#
# Asserts that az command is available
#
assertAzCliIsAvailable () {
    local verbose=${1:-0}
    local cmd=az

    assertCommandIsAvailable $cmd
    logDebug "$("$cmd" --version)" $verbose
}

#
# Install azure cli using apt
# Requires sudo
#
azCliInstall () {
   logInfo "Installing Azure CLI"

   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

   logInfo "Installed Azure CLI on this system"
}

#
# Ensure that Azure CLI is installed on this system
#
ensureAzureCliIsInstalled () {
    local cmd=az
    local available=$(commandIsAvailable "$cmd")

    if [ $available == 0 ]; then
        logInfo "$cmd is not installed on the system; installing '$cmd'"
        azCliInstall
    else
        logInfo "'$cmd' already on the system"
    fi
}

#
# Set up Azure CLI
#
azCliSetup () {
    local verbose=${1:-0}

    logHeader3 "Setting up Azure CLI"

    ensureAzureCliIsInstalled

    assertAzCliIsAvailable $verbose
}