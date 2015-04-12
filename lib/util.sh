#!/bin/bash

## Basic utility functions

[[ -z "$UTIL" ]] && declare UTIL=true || return;

# (String text) => String flattened 
function UTIL::flatten() {
    local text="$@"
    text="${@//$'\n'/\\n}";
    text="${text//$'\t'/\\t}";
    echo "$text"
}

# (String flattened) => String text
function UTIL::expand() {    
    echo -e "$@";
}
