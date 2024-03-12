#!/usr/bin/env bash
set -e

source scripts/log_helpers.sh
source scripts/os_helpers.sh

export debug=0
export verbose=0

showHelp() {
cat << EOF
Usage: ./devenv_2.sh [-hdv]
Bootstrap development environment - phase 2

-h, -help,              --help              Display this help
-d, -debug,             --debug             Debug output (set -xv) 
-v, -verbose,           --verbose           Verbose output

EOF
}

options=$(getopt -l "help,debug,verbose" -o "hdv" -a -- "$@")

if [ $? != 0 ] ; then logFatal "Terminating ..." ; exit 1 ; fi

eval set -- "$options"

while true
do
case "$1" in
-h|--help)
    showHelp
    exit 0
    ;;
-d|--debug)
    export debug=1
    set -xv  # Set xtrace and verbose mode.
    ;;
-v|--verbose)
    export verbose=1
    ;;
--)
    shift
    break;;
esac
shift
done

logHeader1 "Setting up Development Environment - phase 2"

if ! [ -d $ZSH ]; then
    logHeader2 "Configuring zsh shell with oh-my-zsh"
    sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

logHeader2 "Configuring PowerLevel10k for zsh in '$ZSH_CUSTOM/themes/powerlevel10k"

# Must set ZSH_CUSTOM, because it is not known in the bash context
export ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
export PL10K=$ZSH_CUSTOM/themes/powerlevel10k

if ! [ -d $PL10K ]; then 
    logInfo "Cloning powerlevel10k into '$PL10K'"
    git clone https://github.com/romkatv/powerlevel10k.git $PL10K
fi
pushd $PL10K
logInfo "Syncing '$PL10K' with remote"
git pull
popd

export PL10K_THEME="powerlevel10k/powerlevel10k"
logInfo "Updating ZSH_THEME in '$HOME/.zshrc' to '$PL10K_THEME'"
sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"$PL10K_THEME\"|" $HOME/.zshrc

export PL10K_FONT=fonts-firacode
logInfo "Installing font '$PL10K_FONT'"
sudo apt install $PL10K_FONT -y

logHeader2 "Setup development completed - phase 2"
logInfo "Open zsh shell and run from '$HOME' 'p10k configure'"