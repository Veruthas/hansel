#!/bin/bash

# VARIABLES
declare -r HANSEL_PATH="$(realpath $(dirname $0))"

declare ARGUMENTS="$@";


# IMPORTS
source "$HANSEL_PATH/options.sh"
source "$HANSEL_PATH/logging.sh"

# MAIN

set_log_file "hansel.log";
set_log_data "Hello, world\n";
enable_logging;
log;

process "$ARGUMENTS";
