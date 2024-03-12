#!/usr/bin/env bash

source scripts/log_helpers.sh
source scripts/os_helpers.sh

#
# Initializes git config
#
gitConfigInit () {
    local username=$1
    local useremail=$2
    local verbose=${3:-0}

    logHeader3 "Initializing git settings"

    git config --global user.name "$username"
    git config --global user.email "$useremail"
    git config --global color.ui auto
    git config --global core.autocrlf input
    
    # workaround to handle windows path
    ln -sf "/mnt/c/Program Files (x86)/Git Credential Manager/git-credential-manager.exe" $HOME/.local/bin/git-credential-manager.exe
    git config --global credential.helper $HOME/.local/bin/git-credential-manager.exe

    # Required for Azure DevOps (see https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/faq.md) 
    # TODO: Move to .gitattributes?
    git config --global credential.https://dev.azure.com.useHttpPath true

    logDebug "$(git config --list)" $verbose
}

#
# Load repository info from configuration file and clone them into given directory
#
gitCloneRepositories () {
    local repobase=$1
    local repofile=$2
    local clean=${3:-0}
    local verbose=${4:-0}

    logHeader2 "Cloning git repositories"

    while read -r repoinfo; do
        reponame=$(echo "$repoinfo" | awk -F'/' '{print $NF}')
        repodir="$repobase/$reponame"

        logHeader3 "Setting up repository '$reponame' in '$repodir'"

        if [ -d $repodir ] && [ $clean == 1 ]; then
            logInfo "Removing repository '$reponame' from directory '$repodir'"
            rm -rf $repodir 2> /dev/null
        fi

        if ! [ -d $repodir ]; then
            pushd $repobase
            logInfo "Cloning repository '$repoinfo' into directory '$repobase'"
            git clone $repoinfo
            popd
        fi

        logInfo "Syncing '$repoinfo' with remote"
        git fetch origin --prune
        git pull

    done < $repofile
}