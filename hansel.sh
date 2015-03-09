#!/bin/bash

# VARIABLES
declare -r SCRIPT_PATH="$(realpath $(dirname $0))"

declare -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$SCRIPT_PATH/errors.sh";
debug_simple_header
error_simple_header

source "$SCRIPT_PATH/options.sh";

declare -A
echo
# MAIN
#process_line "$@";
list_vars