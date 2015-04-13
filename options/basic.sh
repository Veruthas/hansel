#!/bin/bash

## Implements options for generic functionality (do,if,ignore,pause)

DEBUG::off OPTIONS_BASIC;

# (String command) -> eval command
OPTIONS::add 'do' 'BASIC::do';
function BASIC::do() {

    alert OPTIONS_BASIC 'in do'
    
    eval "$@";
}


# (String condition, ...) -> if condition ...
OPTIONS::add 'if' 'BASIC::if';
function BASIC::if() {
    
    local condition="$1";
    shift;
    
    alert OPTIONS_BASIC "in if <$condition>"
    
    eval "$condition";
    
    [[ "$?" == 0 ]] && OPTIONS::process "$@";
}


# (...) -> ...
OPTIONS::add 'ignore' 'BASIC::ignore';
function BASIC::ignore() {
    
    alert OPTIONS_BASIC "in ignore"
    
    OPTIONS::process "$@";
}


# (String? prompt) -> prompt
OPTIONS::add 'pause' 'BASIC::pause';
function BASIC::pause() {
    
    local prompt="${1:-Press any key to continue...}";
    
    alert OPTIONS_BASIC "in pause <$prompt>"        
    
    read -p "$prompt";        
}

# TODO: Some sort of ask?