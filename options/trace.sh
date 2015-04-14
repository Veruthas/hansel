#!/bin/bash

## Implements file tracing (pops off commands one at a time from the file)
DEBUG::off TRACE

# virtual () => String trace_file
function TRACE::trace_file() {
    echo $HOME/.trace;
}

# (String file);
function TRACE::set_trace_file() {
    local file="$1";
    
    cp -rv "$file" "$(TRACE::trace_file)";
}


# (String? file) -> traces file
OPTIONS::add 'trace' TRACE::option_trace;
function TRACE::option_trace() {
    
    if [[ -n "$1" ]]; then
        TRACE::set_trace_file "$1";
    fi
    
    local trace_file=$(TRACE::trace_file);
    
    while true; do
    
        local line=$(FILE::pop_line "$trace_file");
    
        "$SCRIPT_FILE" "$line";
        
        if (( "$?" != 0 )); then
            throw 1 "Error processing line, run trace again to continue...";
            return 1;
        fi
    done
}