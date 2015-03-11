#!/bin/bash

## Basic utility functions

# (String text) => String flattened 
function flatten() {
    echo ${@//$'\n'/\\n};
}

# (String flattened) => String text
function expand() {    
    echo -e "$@";
}