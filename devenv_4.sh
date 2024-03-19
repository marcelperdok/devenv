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

logHeader1 "Setting up Development Environment - phase 4"

aptPrepare

logHeader2 "Complete zsh setup"
zshSetupPlugins
zshSetupAliases

logHeader2 "Setting up GoLang for development"
goSetup "1.22.1" $verbose

logHeader2 "Setting up Azure components for development"
azCliSetup $verbose

logHeader2 "Setting up Docker for development"
dockerSetup $verbose

logHeader2 "Setting up Kubernetes components for development"
kubeClientSetup $verbose

logHeader3 "Setting up kind"
/usr/local/go/bin/go install sigs.k8s.io/kind@v0.22.0

logHeader2 "Setup of Development Environment completed"