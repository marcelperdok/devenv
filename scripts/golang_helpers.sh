#!/usr/bin/env bash

#
# Setup golang
#
goSetup () {
    local goversion=${1:-"1.22.1"}
    local verbose=${2:-0}

    local available=$(commandIsAvailable go)
    if [ $available == 0 ]; then
        local goos="linux"
        local goarch="amd64"
        local gofile="go${goversion}.${goos}-${goarch}.tar.gz"
        local gosrc="https://go.dev/dl/$gofile"
        local tmp="$HOME/tmp"
        local gotgt="$tmp/go${goversion}.${goos}-${goarch}.tar.gz"
        
        assertCommandIsAvailable curl

        logInfo "Downloading go ${goversion}"
        curl -fsSL $gosrc -o $gotgt

        logInfo "Extracting '$gotgt' to '/usr/local'"
        pushd $tmp
        sudo tar -xvf $gofile -C /usr/local
        popd

        logDebug "Removing download '$gotgt'" $verbose
        rm -rf $gotgt

        local cfg="$HOME/.zshrc"
        local gopath="$HOME/go"

        cfgSetProperty "$cfg" 'export GOROOT' '/usr/local/go' '=' $verbose
        mkdir -p $gopath 
        cfgSetProperty "$cfg" 'export GOPATH' "$gopath" '=' $verbose
        cfgSetSourceScript "$cfg" "$HOME/.local/config/path/set_golang_path.sh"
        echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' > $HOME/.local/config/path/set_golang_path.sh
    else
        # TODO: Perhaps handle release upgrades based on provided version...
        logInfo "Go already installed"
    fi
}