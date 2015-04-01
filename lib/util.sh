#!/bin/bash

## Basic utility functions

# (String text) => String flattened 
function flatten() {
    local text="$@"
    text="${@//$'\n'/\\n}";
    text="${text//$'\t'/\\t}";
    echo "$text"
}

# (String flattened) => String text
function expand() {    
    echo -e "$@";
}
