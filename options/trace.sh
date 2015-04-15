#!/bin/bash

## Implements file tracing (pops off commands one at a time from the file)
DEBUG::off TRACE

# virtual () => String trace_file
function TRACE::trace_file() {
    echo $HOME/.trace;
}

# (String file);
function TRACE::set_trace_file() {
    alert TRACE "in TRACE::set_trace_file.";
    
    local file="$1";
    
    cp "$file" "$(TRACE::trace_file)";
}


# (String? file) -> traces file
OPTIONS::add 'trace' TRACE::option_trace;
function TRACE::option_trace() {
    alert TRACE "in TRACE::option_trace.";
    
    if [[ -n "$1" ]]; then
        TRACE::set_trace_file "$1";
    fi
    
    local trace_file=$(TRACE::trace_file);
    
    while true; do
    
        local line=$(FILE::pop_line "$trace_file");
        
        
        if [[ -n "$line" ]] && [[ ${line:0:1} != "#" ]]; then
            # TODO: quoting is very wonky, Check for proper quoting?
            eval "$SCRIPT_FILE $line";
            
        elif ! FILE::is_empty "$trace_file"; then 
            break;
        fi
        
        if (( "$?" != 0 )); then
            throw 1 "Error processing line, run trace again to continue...";
            return 1;
        fi
    done
}