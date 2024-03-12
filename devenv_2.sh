#!/usr/bin/env bash
set -e

source scripts/apt_helpers.sh
source scripts/log_helpers.sh
source scripts/os_helpers.sh
source scripts/zsh_helpers.sh

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

zshSetupPowerlevel10k
zshSetupAliases

logHeader2 "Setup development completed - phase 2"
logInfo "Open zsh shell and run from '$HOME' 'p10k configure'"