#!/bin/bash

## Implements options for generic functionality (do,if,ignore,pause)

DEBUG::off BASIC_OPTIONS;

# (String command) -> eval command
OPTIONS::add 'do' 'BASIC::option_do';
function BASIC::option_do() {
    alert BASIC_OPTIONS 'in BASIC::option_do'
    
    eval "$@";
}


# (String condition, ...) -> if condition ...
OPTIONS::add 'if' 'BASIC::option_if';
function BASIC::option_if() {
    alert BASIC_OPTIONS 'in BASIC::option_if';
    
    local condition="$1";
    shift;    
    
    eval "$condition";
    
    [[ "$?" == 0 ]] && OPTIONS::process "$@";
}

# (String question, -y|-n, ...) -> if question ...
OPTIONS::add 'ask' 'BASIC::option_ask';
function BASIC::option_ask() {
    alert BASIC_OPTIONS 'in BASIC::option_ask';
    
    local question="$1"; 
    
    local default=;
        
    if [[ "$2" == '-y' ]] || [[ "$2" == '-n' ]]; then        
        default="${2:1}";
        shift 2;
    else
        shift 1;
    fi
    
    read -e -p "$question" -i "$default" answer;
    
    answer=${answer,,};
    
    if [[ "$answer" == 'y' ]]; then
        OPTIONS::process "$@";
    fi
}

# (...) -> ...
OPTIONS::add 'ignore' 'BASIC::option_ignore';
function BASIC::option_ignore() {    
    alert BASIC_OPTIONS 'in BASIC::option_ignore';
    
    OPTIONS::process "$@";
}


# (String? prompt) -> prompt
OPTIONS::add 'pause' 'BASIC::option_pause';
function BASIC::option_pause() {
    alert BASIC_OPTIONS 'in BASIC::option_pause';
    
    local prompt="${1:-Press any key to continue...}";
    
    read -p "$prompt";        
}