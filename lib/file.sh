#!/bin/bash

## SUMMARY: File utility functions

DEBUG::off FILE;

# (String file) ! 0/1
function FILE::is_empty() {
    local file="$1";
    [[ -z $(cat "$file") ]] && return 0 || return 1;
}

# (String file) => line
function FILE::peek_line() {
    local file="$1";
    
    if [[ -e "$file" ]]; then
    
        head "$file" -n 1;
        
    fi
}

# (String file) => line -> file - line
function FILE::pop_line() {
    local file="$1";
    
    if [[ -e "$file" ]]; then
    
        local line=$(head "$file" -n 1);
        
        local rest=$(tail "$file" -n +2);
        
        echo "$rest" > "$file";
        
        echo "$line";
    fi
}

# (String file, String line...) -> line + file 
function FILE::push_line() {
    local file="$1"; shift;        
    
    local data=$([[ -e "$file" ]] && cat $file);
    
    > "$file";
    
    while [[ -n "$1" ]]; do
        echo "$1" >> "$file";
        shift;
    done
    
    echo "$data" >> "$file";
}