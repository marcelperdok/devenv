#!/usr/bin/env bash

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
NOCOLOR='\033[0m'

#
# Prints header1
#
logHeader1 () {
    local txt=$1

    echo -e "${GREEN}################################################################################${NOCOLOR}"
    echo -e "${GREEN}##${NOCOLOR}"
    echo -e "${GREEN}## ($(dateRfc)) $txt${NOCOLOR}"
    echo -e "${GREEN}##${NOCOLOR}"
}

#
# Prints header2
#
logHeader2 () {
    local txt=$1

    echo -e "${GREEN}##------------------------------------------------------------------------------${NOCOLOR}"
    echo -e "${GREEN}## ($(dateRfc)) $txt${NOCOLOR}"
}

#
# Prints header3
#
logHeader3 () {
    local txt=$1

    echo -e "${GREEN}## ($(dateRfc)) $txt${NOCOLOR}"
}

#
# Prints debug message
#
logDebug () {
    local txt=$1
    local verbose=${2:-0}

    if [ $verbose == 1 ]; then
        echo -e "${BLUE}## ($(dateRfc)) DEBUG:   >> $txt${NOCOLOR}"
    fi
}


#
# Prints info message
#
logInfo () {
    local txt=$1

    echo -e "${WHITE}## ($(dateRfc)) INFO:    >> $txt${NOCOLOR}"
}

#
# Prints error message
#
logError () {
    local txt=$1

    echo -e "${RED}## ($(dateRfc)) ERROR:   >> $txt${NOCOLOR}" >&2
}

#
# Prints fatal message
#
logFatal () {
    local txt=$1

    echo -e "${PURPLE}##${NOCOLOR}" >&2
    echo -e "${PURPLE}## ($(dateRfc)) FATAL:   >> $txt${NOCOLOR}" >&2
    echo -e "${PURPLE}##${NOCOLOR}" >&2
} 

#
# Prints warning message
#
logWarn () {
    local txt=$1

    echo -e "${YELLOW}## ($(dateRfc)) WARNING: >> $txt${NOCOLOR}" >&2
} 

#
# Prints TODO message
#
logTodo () {
    local txt=$1

    echo -e "${CYAN}## ($(dateRfc)) TODO   : >> $txt${NOCOLOR}" >&2
} 