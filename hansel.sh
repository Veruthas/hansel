#!/bin/bash

# VARIABLES
declare -r SCRIPT_PATH="$(realpath $(dirname $0))"

declare -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$SCRIPT_PATH/errors.sh";

debug_simple_header
debug_on OPTIONS

source "$SCRIPT_PATH/options.sh";

# MAIN
process_line "$@";
