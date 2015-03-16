#!/bin/bash

## Implements options for generic functionality (do,if,ignore,pause)

DEBUG::off OPTIONS_BASIC;

# (String command) -> eval command
OPTIONS::add 'do';
function OPTIONS::do() {

    alert OPTIONS_BASIC 'in do'
    
    eval "$@";
}


# (String condition, ...) -> if condition ...
OPTIONS::add 'if';
function OPTIONS::if() {
    
    local condition="$1";
    shift;
    
    alert OPTIONS_BASIC "in if <$condition>"
    
    eval "$condition";
    
    [[ "$?" == 0 ]] && OPTIONS::process "$@";
}


# (...) -> ...
OPTIONS::add 'ignore';
function OPTIONS::ignore() {
    
    alert OPTIONS_BASIC "in ignore"
    
    OPTIONS::process "$@";
}


# (String? prompt) -> prompt
OPTIONS::add 'pause';
function OPTIONS::pause() {
    
    local prompt="${1:-Press any key to continue...}";
    
    alert OPTIONS_BASIC "in pause <$prompt>"        
    
    read -p "$prompt";        
}

# TODO: Some sort of ask?