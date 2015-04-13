#!/bin/bash

## Implements options for generic functionality (do,if,ignore,pause)

DEBUG::off OPTIONS_BASIC;

# (String command) -> eval command
OPTIONS::add 'do' 'BASIC::option_do';
function BASIC::option_do() {

    alert OPTIONS_BASIC 'in do'
    
    eval "$@";
}


# (String condition, ...) -> if condition ...
OPTIONS::add 'if' 'BASIC::option_if';
function BASIC::option_if() {
    
    local condition="$1";
    shift;
    
    alert OPTIONS_BASIC "in if <$condition>"
    
    eval "$condition";
    
    [[ "$?" == 0 ]] && OPTIONS::process "$@";
}


# (...) -> ...
OPTIONS::add 'ignore' 'BASIC::option_ignore';
function BASIC::option_ignore() {
    
    alert OPTIONS_BASIC "in ignore"
    
    OPTIONS::process "$@";
}


# (String? prompt) -> prompt
OPTIONS::add 'pause' 'BASIC::option_pause';
function BASIC::option_pause() {
    
    local prompt="${1:-Press any key to continue...}";
    
    alert OPTIONS_BASIC "in pause <$prompt>"        
    
    read -p "$prompt";        
}

# TODO: Some sort of ask?