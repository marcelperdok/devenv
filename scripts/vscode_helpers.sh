#!/usr/bin/env bash

#
# Install vscode extensions
#
vscodeInstallExtensions () {
    local extensionfile=${1:-$HOME/.vscode_extensions}
    local verbose=${2:-0}

    logHeader2 "Setting up visual studio code extensions"

    while read -r extension; do
        logHeader3 "Installing extension '$extension'"
        code --install-extension "$extension" --force
    done < $extensionfile
}