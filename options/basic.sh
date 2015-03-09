#!/bin/bash

## Implements options for generic functionality (do,if,ignore,pause)

debug_off OPTIONS_BASIC;

# (String command) -> eval command
add_option 'do';
function option_do() {
    alert OPTIONS_BASIC 'in do'
    eval "$@";
}


# (String condition, ...) -> if condition ...
add_option 'if';
function option_if() {
    
    local condition="$1";
    shift;
    
    alert OPTIONS_BASIC "in if <$condition>"
    
    eval "$condition";
    
    [[ "$?" == 0 ]] && process "$@";
}


# (...) -> ...
add_option 'ignore';
function option_ignore() {
    alert OPTIONS_BASIC "in ignore"
    process "$@";
}


# (String? prompt) -> prompt
add_option 'pause';
function option_pause() {
    
    local prompt="${1:-Press any key to continue...}";
    
    alert OPTIONS_BASIC "in pause <$prompt>"        
    
    read -p "$prompt";        
}