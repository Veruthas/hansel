#!/bin/bash

# VARIABLES
declare -r HANSEL_PATH="$(realpath $(dirname $0))"

declare SCRIPT_ARGUMENTS="$@";


# IMPORTS
source "$HANSEL_PATH/logging.sh"
source "$HANSEL_PATH/options.sh"

# MAIN
process_line "$SCRIPT_ARGUMENTS";
