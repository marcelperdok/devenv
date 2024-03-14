#!/usr/bin/env bash

#
# Setup docker
#
dockerSetup () {
    local verbose=${1:-0}

    logHeader3 "Setting up docker"

    local available=$(commandIsAvailable docker)
    if [ $available == 0 ]; then
        assertCommandIsAvailable curl

        logInfo "Downloading docker script"
        sudo curl -fsSL https://get.docker.com -o get-docker.sh

        logInfo "Install docker"
        sudo sh ./get-docker.sh

        logInfo "Adding current user '$USER' to docker group"
        sudo usermod -aG docker "$USER"

        logInfo "Make sure docker socket '/var/run/docker.sock' is useable for everyone"
        sudo chmod 666 /var/run/docker.sock

        logDebug "$(ls -l /var/run/docker.sock)" $verbose
    else
        logInfo "Docker already installed"
    fi

    assertCommandIsAvailable docker
    logDebug "$(docker --version)" $verbose
}