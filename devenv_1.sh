#!/usr/bin/env bash
set -e

source scripts/apt_helpers.sh
source scripts/azure_helpers.sh
source scripts/git_helpers.sh
source scripts/kubernetes_helpers.sh
source scripts/log_helpers.sh
source scripts/os_helpers.sh

export debug=0
export verbose=0
export username=$USER
export useremail=$username@$(hostname)
export repobase=$HOME/repos
export repofile=$HOME/.repos
export setuprepositories=0
export clonerepositories=0

showHelp() {
cat << EOF
Usage: ./devenv_1.sh [-hcdiln:r:f:tuv --cleanrepositories --clonerepositories]
Bootstrap development environment

-h, -help,              --help              Display this help
-n, -username,          --username          Your name [default: '$username']
-e, -useremail,         --useremail         Your email [default: '$useremail']
-r, -repobase,          --repobase          Absolute path to the directory for your git repositories [default: '$repobase'] 
                        --cleanrepositories Removes the repositories defined in '$repofile' before cloning them
                        --setuprepositories Configures the git repositories for development in repobase based on the config in '$repofile'

-d, -debug,             --debug             Debug output (set -xv) 
-v, -verbose,           --verbose           Verbose output

EOF
}

options=$(getopt -l "help,debug,cleanrepositories,setuprepositories,name:,email:,repobase:,verbose" -o "hdn:e:r:v" -a -- "$@")

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
-r|--repobase)
    shift
    export repobase="$1"
    ;;
--cleanrepositories)
    export cleanrepositories=1
    ;;
--setuprepositories)
    export setuprepositories=1
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

logHeader2 "Configuring git environment"
assertCommandIsAvailable git
logInfo "$(git --version)"
gitConfigInit $username $useremail $verbose

logHeader2 "Creating directories"
logInfo "Creating $HOME/.local/bin"
mkdir -p $HOME/.local/bin

logHeader2 "Preparing apt package manager"
logHeader3 "Updating apt"
sudo apt update -y

logHeader3 "Removing unused apt packages"
sudo apt autoremove -y

logHeader3 "Upgrading apt"
sudo apt upgrade -y

logHeader2 "Install required apt packages"
logHeader3 "Installing apt libraries"
aptPackageSetup apt-transport-https
aptPackageSetup ca-certificates

logHeader3 "Installing apt tools"
aptCommandSetup zsh zsh $verbose
aptCommandSetup curl curl $verbose
aptCommandSetup wget wget $verbose

logHeader2 "Setting up Azure components for development"
azCliSetup $verbose

logHeader2 "Setting up Kubernetes components for development"
kubeClientSetup $verbose

gitSetupDevelopmentRepositories $repobase $repofile $setuprepositories $cleanrepositories $verbose

logHeader2 "Configuring ZSH as default shell for user '$USER'"
ensureDefaultShellIsZsh

logHeader2 "Setup development completed - phase 1"
logInfo "Log out and in again to switch to zsh shell and continue with devenv_2.sh"
logInfo "When prompted for intial zsh setup, select option '2'"