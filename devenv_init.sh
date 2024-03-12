#!/usr/bin/env bash
set -e

# Run this script from the home directory of your WSL2 user, e.g. /home/dev

showHelp() {
cat << EOF
Usage: ./devenv_init.sh [-hcdiln:r:f:tuv]
Bootstrap development environment

-h, -help,              --help              Display this help
-n, -username,          --username          Your name
-e, -useremail,         --useremail         Your email
-r, -repobase,          --repobase          Absolute path to the directory for your git repositories 
-c, -clean,             --clean             Clean development environment (Be carefull!!)

-d, -debug,             --debug             Debug output
-v, -verbose,           --verbose           Verbose output

EOF
}

pushd () { command pushd "$@" > /dev/null; }
popd () { command popd "$@" > /dev/null; }

export clean=0
export debug=0
export verbose=0
export username=$USER
export useremail=$username@$(hostname)
export repobase=$HOME/repos

options=$(getopt -l "help,clean,debug,name:,email:,verbose " -o "hcdn:e:v" -a -- "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$options"

while true
do
case "$1" in
-h|--help)
    showHelp
    exit 0
    ;;
-c|--clean)
    export clean=1
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
--)
    shift
    break;;
esac
shift
done

echo "Initializing Development Environment"
echo "Started on $(date)"

if [ ! command -v git &> /dev/null ];
then
    echo "ERROR: git command could not be found"
    exit 1
fi

# Clean
if [ $clean == 1 ];
then
    echo "* Cleaning git repository base directory '$repobase'"
fi

echo "* Creating initial git repository base directory '$repobase'"
mkdir -p $repobase

# Load devenv.sh from GitHub repository
echo "* Setting up devenv repository"
echo "* Using git version: $(git --version)"
pushd $repobase
if [ $clean == 1 ];
then
    echo "* Cloning repository from github.com"
    git clone https://github.com/marcelperdok/devenv.git
else
    echo "* Updating repository from remote"
    pushd $repobase/devenv
    git fetch origin --prune
    git pull
    popd
fi
popd

echo "Starting $repobase/devenv/devenv.sh"
echo "Completed on $(date)"