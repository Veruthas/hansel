#!/bin/bash

shopt -s expand_aliases

alias global='declare -g';


# VARIABLES
global -r SCRIPT_FILE="$(realpath $0)";

global -r SCRIPT_PATH="$(dirname $(realpath $0))"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS

# errors is a base file, want to load this before anything else
source "$SCRIPT_PATH/errors.sh";


for lib in "$SCRIPT_PATH/lib"/*; do
    source "$lib";
done


source "$SCRIPT_PATH/options.sh";

# needs to be loaded last
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