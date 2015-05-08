#!/bin/bash

## Implements file tracing (pops off commands one at a time from the file)
DEBUG::off TRACE_OPTIONS

global TRACE_OPTIONS_TRACE_FILE_NAME="trace.dat";

# virtual () => String trace_directory
function TRACE_OPTIONS::trace_file_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String trace_file
function TRACE_OPTIONS::trace_file_path() {
    echo "$(TRACE_OPTIONS::trace_file_directory)/$TRACE_OPTIONS_TRACE_FILE_NAME";
}

# (String file);
function TRACE_OPTIONS::set_trace_file() {
    alert TRACE_OPTIONS "in TRACE_OPTIONS::set_trace_file.";
    
    local file="$1";
    
    cp "$file" "$(TRACE_OPTIONS::trace_file_path)";    
}


# (String? file) -> traces file
OPTIONS::add 'trace' 'TRACE_OPTIONS::option_trace';
function TRACE_OPTIONS::option_trace() {
    alert TRACE_OPTIONS "in TRACE_OPTIONS::option_trace.";
    
    if [[ -n "$1" ]]; then
        TRACE_OPTIONS::set_trace_file "$1";
    fi
    
    local trace_file=$(TRACE_OPTIONS::trace_file_path);
    
    local line_no=0;
    
    while true; do
    
        local line=$(FILE::peek_line "$trace_file");
        
        local err_no=0;
        
        if [[ -n "$line" ]] && [[ ! "$line" =~ ^[\ ]*# ]]; then
            # TODO: quoting is very wonky, Check for proper quoting?
            eval "$SCRIPT_FILE $line";
            err_no=$?;
        elif [[ ! -e "$trace_file" ]] || FILE::is_empty "$trace_file"; then 
            break;
        fi
        
        if (( err_no != 0 )); then                        
            throw 1 "Error processing line #$line_no: '$line'; run trace again to continue...";
            return 1;
        fi
        (( line_no++ ))
        FILE::pop_line "$trace_file" "$line";
    done
}