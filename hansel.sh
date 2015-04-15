#!/bin/bash

shopt -s expand_aliases

alias global='declare -g';


# VARIABLES
global -r SCRIPT_FILE="$(realpath $0)";

global -r SCRIPT_PATH="$(dirname $(realpath $0))"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS
source "$SCRIPT_PATH/lib/errors.sh";


source "$SCRIPT_PATH/lib/util.sh"

source "$SCRIPT_PATH/lib/file.sh"

source "$SCRIPT_PATH/lib/nodes.sh"


source "$SCRIPT_PATH/options.sh";

source "$SCRIPT_PATH/settings.sh";

# TODO: help
#source "$SCRIPT_PATH/help.sh";


# MAIN
function HANSEL::main() {
    
    [[ ! -d "$(SETTINGS::settings_path)" ]] && mkdir "$(SETTINGS::settings_path)";
    
    OPTIONS::process_line "$@";
}


# MISC SETUP
DEBUG::on;

if DEBUGGING; then

    DEBUG::set_simple_header;
    ERROR::set_simple_header;    
    HANSEL::main "$@";     
else

    HANSEL::main "$@";
fi