#!/usr/bin/env bash
set -e

source scripts/git_helpers.sh
source scripts/install_helpers.sh
source scripts/log_helpers.sh
source scripts/os_helpers.sh

export debug=0
export verbose=0
export username=$USER
export useremail=$username@$(hostname)
export repobase=$HOME/repos
export repofile=$HOME/.repos
export cleanrepositories=0
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
                        --clonerepositories Clones the repositories into repobase based on the config in '$repofile'

-d, -debug,             --debug             Debug output (set -xv) 
-v, -verbose,           --verbose           Verbose output

EOF
}

options=$(getopt -l "help,debug,cleanrepositories,clonerepositories,name:,email:,repobase:,verbose" -o "hdn:e:r:v" -a -- "$@")

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
--clonerepositories)
    export clonerepositories=1
    ;;
--)
    shift
    break;;
esac
shift
done

logHeader1 "Setting up Development Environment - phase 1"

logHeader2 "Configuring git environment"
assertInstalled git
logInfo "$(git --version)"
gitConfigInit $username $useremail $verbose

logHeader2 "Synchronizing WSL2 clock"
sudo hwclock -s

logHeader2 "Creating directories"
logInfo "Creating $HOME/.local/bin"
mkdir -p $HOME/.local/bin

logHeader2 "Preparing apt"
logHeader3 "Updating apt"
sudo apt update -y

logHeader3 "Removing unused apt packages"
sudo apt autoremove -y

logHeader3 "Upgrading apt"
sudo apt upgrade -y

logHeader2 "Installing apt packages"
setupAptPackage zsh zsh $verbose
setupAptPackage curl zsh $verbose
setupAptPackage wget wget $verbose

if [ $clonerepositories == 1 ]; then
    gitCloneRepositories $repobase $repofile $cleanrepositories $verbose
fi

logHeader2 "Switching default shell to zsh"
chsh -s $(which zsh)

logHeader2 "Setup development completed - phase 1"
logInfo "Log out and in again to switch to zsh shell and continue with devenv_2.sh"
logInfo "When prompted for intial zsh setup, select option '2'"