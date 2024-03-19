#!/usr/bin/env bash

#
# Check if key exists in config file
#
cfgKeyExists () {
    local cfg=$1
    local key=$2

    if ! [ -f $cfg ]; then
        logFatal "File '$cfg' does not exist; aborting"
    fi

    local result=$(grep "^$key" $cfg | wc -l)
    if [ $result == 0 ]; then
        echo 0
    else
        echo 1   
    fi
}

#
# Adds single line property in given configuration file with given value 
#
cfgAddProperty () {
    local cfg=$1
    local key=$2
    local value=$3
    local operator=${4:-"="}
    local verbose=${5:-0}

    local hasKey=$(cfgKeyExists $cfg "$key")
    if ! [ $hasKey == 0 ]; then
        logFatal "File '$cfg' already has property '$key'; aborting"
    fi

    logInfo "Adding property '$key' with value '$value' and operator '$operator' to file '$cfg'"
    echo >> $cfg
    echo "# Added by devenv scripting on $(dateRfc)" >> $cfg
    echo "${key}${operator}${value}"  >> $cfg
}

#
# Updates single line property in given configuration file with given value 
#
cfgUpdateProperty () {
    local cfg=$1
    local key=$2
    local value=$3
    local operator=${4:-"="}
    local verbose=${5:-0}

    local hasKey=$(cfgKeyExists $cfg "$key")
    if [ $hasKey == 0 ]; then
        logFatal "File '$cfg' does not have property '$key'; aborting"
    fi

    logInfo "Updating property '$key' with value '$value' and operator '$operator' in file '$cfg'"
    sed -i "s|^${key}${operator}.*|${key}${operator}${value}|" $cfg
}

#
# Sets single line property in given configuration file with given value 
# Adds the key and value if key is not yet available
#
cfgSetProperty () {
    local cfg=$1
    local key=$2
    local value=$3
    local operator=${4:-"="}
    local verbose=${5:-0}

    local hasKey=$(cfgKeyExists $cfg "$key")
    if [ $hasKey == 0 ]; then
        logInfo "File '$cfg' does not have property '$key'; adding property"
        cfgAddProperty $cfg "$key" "$value" "$operator" $verbose
    else
        logInfo "File '$cfg' already has property '$key'; updating property"
        cfgUpdateProperty $cfg "$key" "$value" "$operator" $verbose
    fi
}

#
# Check if source statement exists in config file
#
cfgSourceScriptExists () {
    local cfg=$1
    local script=$2

    if ! [ -f $cfg ]; then
        logFatal "File '$cfg' does not exist; aborting"
    fi

    local result=$(grep "source $script" $cfg | wc -l)
    if [ $result == 0 ]; then
        echo 0
    else
        echo 1   
    fi
}

#
# Adds source script entry in given configuration file
#
cfgAddSourceScript () {
    local cfg=$1
    local script=$2
    local verbose=${3:-0}

    local exists=$(cfgSourceScriptExists $cfg "$script")
    if ! [ $exists == 0 ]; then
        logFatal "File '$cfg' already has 'source $script' entry; aborting"
    fi

    logInfo "Adding entry 'source $script' to file '$cfg'"
    echo >> $cfg
    echo "# Added by devenv scripting on $(dateRfc)" >> $cfg
    local condition="[[ ! -f $script ]] ||"
    echo "${condition} source ${script}"  >> $cfg
}

#
# Updates single line source script entry in given file
#
cfgUpdateSourceScript () {
    local cfg=$1
    local script=$2
    local verbose=${3:-0}

    local exists=$(cfgSourceScriptExists $cfg "$script")
    if [ $exists == 0 ]; then
        logFatal "File '$cfg' does not have entry 'source $script'; aborting"
    fi

    logInfo "Updating entry 'source $script' to 'source $script' in file '$cfg'"
    local condition="[[ ! -f $script ]] ||"
    sed -i "s%.*source ${script}.*%${condition} source ${script} # Updated on $(dateRfc) by devenv scripting%" $cfg
}

#
# Sets source script statement in given file
#
cfgSetSourceScript () {
    local cfg=$1
    local script=$2
    local verbose=${3:-0}

    local hasSourceScript=$(cfgSourceScriptExists $cfg "$script")
    if [ $hasSourceScript == 0 ]; then
        logInfo "File '$cfg' does not have source script 'source $script'; adding entry"
        cfgAddSourceScript $cfg $script $verbose
    else
        logInfo "File '$cfg' already has source script 'source $script'; updating entry"
        cfgUpdateSourceScript $cfg $script $verbose
    fi
}
