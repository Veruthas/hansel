#!/bin/bash

shopt -s expand_aliases

alias global='declare -g';


# VARIABLES
global -r SCRIPT_PATH="$(realpath $(dirname $0))"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS

source "$SCRIPT_PATH/lib/errors.sh";


source "$SCRIPT_PATH/lib/util.sh"

source "$SCRIPT_PATH/lib/nodes.sh"


source "$SCRIPT_PATH/options.sh";



# MISC SETUP
DEBUG::off;

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
