#!/bin/bash

shopt -s expand_aliases

alias global='declare -g';


# VARIABLES
global -r SCRIPT_PATH="$(realpath $(dirname $0))"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$SCRIPT_PATH/errors.sh";


source "$SCRIPT_PATH/util.sh"

source "$SCRIPT_PATH/archive_util.sh";


source "$SCRIPT_PATH/options.sh";



# MISC SETUP
DEBUG::on;

if DEBUGGING; then

DEBUG::set_simple_header
ERROR::set_simple_header

function VARS::var_file() {
    echo "$SCRIPT_PATH/../vars";
}


fi


# MAIN
function HANSEL::main() {
    OPTIONS::process_line "$@";
}

HANSEL::main "$@";

global storage="$SCRIPT_PATH/../storage"



