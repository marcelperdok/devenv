#!/usr/bin/env bash

#
#  Setup zsh aliases
#
zshSetupAliases () {
    local aliassrc=${1:-resources/.zsh_aliases}
    local aliastgt=${2:-$HOME/.zsh_aliases}

    logHeader2 "Configuring aliases and autocompletion for zsh"

    logInfo "Copy '$aliassrc' from devenv repository to '$aliastgt'"
    cp -f $aliassrc $aliastgt

    local zshrc=$HOME/.zshrc
    local result=$(grep "^source $aliastgt" $zshrc | wc -l)
    if [ $result == 0 ]; then
        logInfo "Updating $zshrc file with alias configuration '$aliastgt'"
        
        echo >> $zshrc
        echo >> $zshrc
        echo "# Added by devenv scripting on $(dateRfc)" >> $zshrc
        echo "source $aliastgt" >> $zshrc
    else
        logInfo "$zshrc already includes custom aliases defined in '$aliastgt'"
    fi
}

#
# Setup zsh theme
#
zshSetupTheme () {
    local theme=${1:-powerlevel10k/powerlevel10k}
    local zshrc=$HOME/.zshrc

    logHeader3 "Updating ZSH_THEME in '$zshrc' to '$theme'"
    sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"$theme\"|" $zshrc
}

#
# Setup Powerlevel10k for Zsh
#
zshSetupPowerlevel10k () {
    local zshcustom=${1:-$HOME/.oh-my-zsh/custom}

    logHeader2 "Configuring PowerLevel10k for zsh"

    local pl10k=$zshcustom/themes/powerlevel10k
    logHeader3 "Updating Powerlevel10k repository '$pl10k'"

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
