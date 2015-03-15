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

source "$SCRIPT_PATH/archive_util.sh";

# MAIN
#process_line "$@";
global storage_path="$SCRIPT_PATH/../storage";

ARCHIVE::import_file "errors.sh" "$storage_path" "File0"
ARCHIVE::import_file "util.sh" "$storage_path" "File0"
ARCHIVE::import_file "options.sh" "$storage_path" "File0"
ARCHIVE::import_file "archive_util.sh" "$storage_path" "File0" 1
read -p "Press any key to continue...";
ARCHIVE::export_file "$storage_path/File0/extracted_01.sh" "$storage_path" "File0" 1