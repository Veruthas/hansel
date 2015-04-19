#!/bin/bash

## Implements file tracing (pops off commands one at a time from the file)
DEBUG::off TRACE_OPTIONS

global TRACE_OPTIONS_TRACE_FILE_NAME="trace.dat";

# virtual () => String trace_directory
function TRACE::trace_file_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String trace_file
function TRACE::trace_file_path() {
    echo "$(TRACE::trace_directory)/$TRACE_OPTIONS_TRACE_FILE_NAME";
}


# (String file);
function TRACE::set_trace_file() {
    alert TRACE_OPTIONS "in TRACE::set_trace_file.";
    
    local file="$1";
    
    cp "$file" "$(TRACE::trace_file_path)";
}


# (String? file) -> traces file
OPTIONS::add 'trace' TRACE::option_trace;
function TRACE::option_trace() {
    alert TRACE_OPTIONS "in TRACE::option_trace.";
    
    if [[ -n "$1" ]]; then
        TRACE::set_trace_file "$1";
    fi
    
    local trace_file=$(TRACE::trace_file_path);
    
    while true; do
    
        local line=$(FILE::peek_line "$trace_file");
        
        local $err_no=0;
        
        if [[ -n "$line" ]] && [[ ${line:0:1} != "#" ]]; then
            # TODO: quoting is very wonky, Check for proper quoting?
            eval "$SCRIPT_FILE $line";
            $err_no=$?;
        elif ! FILE::is_empty "$trace_file"; then 
            break;
        fi
        
        if (( "$err_no" != 0 )); then                        
            throw 1 "Error processing line '$line'; run trace again to continue...";
            return 1;
        fi
        
        UTIL::pop_line "$trace_file" "$line";
    done
}