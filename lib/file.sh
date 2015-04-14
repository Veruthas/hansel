#!/bin/bash

## File utility functions

DEBUG::off FILE;


# (String file) => line
function FILE::pop_line() {
    local file="$1";
    
    if [[ -e "$file" ]]; then
    
        local line=$(head "$file" -n 1);
        
        local rest=$(tail "$file" -n +2);
        
        echo "$rest" > "$file";
        
        echo "$line";
    fi
}