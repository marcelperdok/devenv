#!/usr/bin/env bash
set -e

source scripts/apt_helpers.sh
source scripts/azure_helpers.sh
source scripts/config_helpers.sh
source scripts/docker_helpers.sh
source scripts/git_helpers.sh
source scripts/golang_helpers.sh
source scripts/kubernetes_helpers.sh
source scripts/log_helpers.sh
source scripts/os_helpers.sh
source scripts/zsh_helpers.sh

export debug=0
export verbose=0
export username=$USER
export useremail=$username@$(hostname)

showHelp() {
cat << EOF
Usage: ./devenv.sh [-de:hn:v]
Bootstrap development environment

-h, -help,              --help              Display this help
-n, -username,          --username          Your name [default: '$username']
-e, -useremail,         --useremail         Your email [default: '$useremail']

-d, -debug,             --debug             Debug output (set -xv) 
-v, -verbose,           --verbose           Verbose output

EOF
}

options=$(getopt -l "help,debug,email:,name:,verbose" -o "de:hn:v" -a -- "$@")

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
-n|--username)
    shift
    export username="$1"
    ;;
-n|--useremail)
    shift
    export useremail="$1"
    ;;
--)
    shift
    break;;
esac
shift
done

logHeader1 "Setting up Development Environment - phase 1"

logHeader2 "Configuring Ubuntu system wide settings"
logHeader3 "Synchronizing WSL2 / Ubuntu system clock"
syncClock

logHeader2 "Creating directories"
logInfo "Creating $HOME/.local/bin"
mkdir -p $HOME/.local/bin
logInfo "Creating $HOME/.local/config/path"
mkdir -p $HOME/.local/config/path
logInfo "Creating $HOME/tmp"
mkdir -p $HOME/tmp

aptPrepare

logHeader2 "Install required apt packages"
logHeader3 "Installing apt libraries"
aptPackageSetup apt-transport-https
aptPackageSetup ca-certificates

logHeader3 "Installing apt tools"
aptCommandSetup git git $verbose
aptCommandSetup zsh zsh $verbose
aptCommandSetup curl curl $verbose
aptCommandSetup wget wget $verbose

logHeader2 "Configuring git environment"
assertCommandIsAvailable git
logInfo "$(git --version)"
gitConfigInit $username $useremail $verbose

logHeader2 "Switch default shell to zsh"
zshSetAsDefaultShell

logHeader2 "Setup phase 1 of Development Environment completed"
logTodo "Log out and in again to switch to zsh shell"
logTodo "When prompted for initial zsh setup, select option '2'"
logTodo "Continue with devenv_2.sh"
