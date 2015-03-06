#!/bin/bash

# VARIABLES
declare -r HANSEL_PATH="$(realpath $(dirname $0))"

declare -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$HANSEL_PATH/logging.sh";
source "$HANSEL_PATH/options.sh";
source "$HANSEL_PATH/options-basic.sh";

set_log_file hansel.log
# MAIN
process_line "$@";
