#!/bin/bash

shopt -s expand_aliases

alias global='declare -g';


# VARIABLES
global -r SCRIPT_PATH="$(realpath $(dirname $0))"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$SCRIPT_PATH/util.sh"

source "$SCRIPT_PATH/errors.sh";
debug_simple_header
error_simple_header

source "$SCRIPT_PATH/options.sh";

function VARS::var_file() {
    echo "$SCRIPT_PATH/../vars";
}

source "$SCRIPT_PATH/file_util.sh";

# MAIN
#process_line "$@";
global storage_path="$SCRIPT_PATH/../storage";

