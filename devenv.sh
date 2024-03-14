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
source scripts/vscode_helpers.sh
source scripts/zsh_helpers.sh

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
Usage: ./devenv.sh [-hcdiln:r:f:tuv --cleanrepositories --clonerepositories]
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

logHeader1 "Setting up Development Environment"

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
logInfo "Creating $HOME/.local/config/path"
mkdir -p $HOME/.local/config/path
logInfo "Creating $HOME/tmp"
mkdir -p $HOME/tmp

# aptPrepare

logHeader2 "Install required apt packages"
logHeader3 "Installing apt libraries"
# aptPackageSetup apt-transport-https
# aptPackageSetup ca-certificates

logHeader3 "Installing apt tools"
# aptCommandSetup zsh zsh $verbose
# aptCommandSetup curl curl $verbose
# aptCommandSetup wget wget $verbose

zshSetup

logHeader2 "Setting up GoLang for development"
goSetup "1.22.1" $verbose

logHeader2 "Setting up Azure components for development"
# azCliSetup $verbose

logHeader2 "Setting up Docker for development"
# dockerSetup $verbose

logHeader2 "Setting up Kubernetes components for development"
# kubeClientSetup $verbose

#vscodeInstallExtensions

gitSetupDevelopmentRepositories $repobase $repofile $setuprepositories $cleanrepositories $verbose

logHeader2 "Setup of Development Environment completed"
logTodo "Log out and in again to switch to zsh shell"
logTodo "When prompted for initial zsh setup, select option '2'"
logTodo "Run 'p10k configure' from your zsh prompt to (re)configure PowerLevel10k"
