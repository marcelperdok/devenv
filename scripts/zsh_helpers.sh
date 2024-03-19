#!/usr/bin/env bash

#
#  Setup zsh aliases
#
zshSetupAliases () {
    local aliassrc=${1:-resources/.zsh_aliases}
    local aliastgt=${2:-$HOME/.zsh_aliases}

    logHeader3 "Configuring aliases and autocompletion for zsh"

    logInfo "Copy '$aliassrc' from devenv repository to '$aliastgt'"
    cp -f $aliassrc $aliastgt

    local zshrc=$HOME/.zshrc
    cfgSetSourceScript $zshrc "$aliastgt" $verbose
}

#
# Sets the default shell for this user to zsh
# Require
#
zshSetAsDefaultShell () {
    logHeader3 "Configuring ZSH as default shell for user '$USER'"
    ensureDefaultShellIsZsh
}

#
# Setup zsh theme
#
zshSetupTheme () {
    local theme=${1:-powerlevel10k/powerlevel10k}
    local zshrc=$HOME/.zshrc

    logInfo "Updating ZSH_THEME in '$zshrc' to '$theme'"
    sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"$theme\"|" $zshrc
}

#
# Setup Powerlevel10k for Zsh
#
zshSetupPowerlevel10k () {
    local zshcustom=${1:-$HOME/.oh-my-zsh/custom}

    logHeader3 "Configuring PowerLevel10k for zsh"

    local pl10k=$zshcustom/themes/powerlevel10k
    logInfo "Updating Powerlevel10k repository '$pl10k'"

    if ! [ -d $pl10k ]; then
        logInfo "Cloning powerlevel10k into '$pl10k'"
        git clone https://github.com/romkatv/powerlevel10k.git $pl10k
    fi

    pushd $pl10k
    logInfo "Syncing '$pl10k' with remote"
    git pull
    popd

    aptPackageSetup fonts-firacode

    zshSetupTheme powerlevel10k/powerlevel10k
}

#
# Setup oh-my-zsh
#
zshSetupOhMyZsh () {
    logHeader3 "Setting up oh-my-zsh"

    local zsh=$HOME/.oh-my-zsh

    if ! [ -d $zsh ]; then
        logInfo "Configuring zsh shell with oh-my-zsh"
        sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    else
        logInfo "Oh-my-zsh already on this system"
    fi
}

#
# Setup zsh auto suggestions plugin
#
zshSetupAutoSuggestionsPlugin () {
    local zshcustom=${1:-$HOME/.oh-my-zsh/custom}
    local plugin=zsh-autosuggestions

    logHeader3 "Setting up '$plugin' plugin for zsh"

    local repo=$zshcustom/plugins/$plugin
    logInfo "Updating $plugin repository '$repo'"

    if ! [ -d $repo ]; then
        logInfo "Cloning $plugin into '$repo'"
        git clone https://github.com/zsh-users/zsh-autosuggestions $repo
    fi

    pushd $repo
    logInfo "Syncing '$repo' with remote"
    git pull
    popd
}

#
# Setup zsh syntax highlighting plugin
#
zshSetupSyntaxHighlightingPlugin () {
    local zshcustom=${1:-$HOME/.oh-my-zsh/custom}
    local plugin=zsh-syntax-highlighting

    logHeader3 "Setting up '$plugin' plugin for zsh"

    local repo=$zshcustom/plugins/$plugin
    logInfo "Updating $plugin repository '$repo'"

    if ! [ -d $repo ]; then
        logInfo "Cloning $plugin into '$repo'"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $repo
    fi

    pushd $repo
    logInfo "Syncing '$repo' with remote"
    git pull
    popd
}

#
# Setup zsh plugins
#
zshSetupPlugins () {
    zshSetupAutoSuggestionsPlugin
    zshSetupSyntaxHighlightingPlugin

    local zshrc=$HOME/.zshrc
    local list='git zsh-syntax-highlighting zsh-autosuggestions'
    logInfo "Updating plugins=() in '$zshrc' to 'plugins=($list)'"
    sed -i "s|^plugins=.*|plugins=( $list )|" $zshrc
}
