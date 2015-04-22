#!/bin/bash +x

shopt -s expand_aliases

alias global='declare -g';


# VARIABLES
global -r SCRIPT_FILE="$(realpath $0)";

global -r SCRIPT_PATH="$(dirname $SCRIPT_FILE)"

global -a SCRIPT_ARGUMENTS=("$@");


# IMPORTS

# errors is a base file, want to load this before anything else
source "$SCRIPT_PATH/errors.sh";

function git_branch() {
    local branch="$(git branch 2>/dev/null)";
    branch=$(echo "$branch" | grep '*');
    echo ${branch//* /};
}

if [[ $(git_branch) == "develop" ]]; then
    DEBUG::on;    
fi


# libraries (no executable code)
for lib in "$SCRIPT_PATH/lib"/*; do
    source "$lib";
done


# options
for options in "$SCRIPT_PATH/options"/*; do
    source "$options";
done


# needs to be loaded last
source "$SCRIPT_PATH/settings.sh";


# TODO: help
#source "$SCRIPT_PATH/help.sh";


# MAIN
function HANSEL::main() {
    
    OPTIONS::process_line "$@";
}


# MISC SETUP

if DEBUGGING; then

    DEBUG::set_simple_header;
    ERROR::set_simple_header;    
    
    HANSEL::main "$@";         
    
else

    HANSEL::main "$@";
fi