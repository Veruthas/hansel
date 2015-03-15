#!/bin/bash

shopt -s expand_aliases

alias global='declare -g';


# DEBUG
declare DEBUG=true;


# VARIABLES
global -r SCRIPT_PATH="$(realpath $(dirname $0))"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$SCRIPT_PATH/errors.sh";


source "$SCRIPT_PATH/util.sh"

source "$SCRIPT_PATH/archive_util.sh";


source "$SCRIPT_PATH/options.sh";



# MISC SETUP
if [[ -n $DEBUG ]]; then

debug_simple_header
error_simple_header

function VARS::var_file() {
    echo "$SCRIPT_PATH/../vars";
}

function FILES::repository_path() {
    echo "$SCRIPT_PATH/../storage"
}

fi

# MAIN
process_line "$@";