#!/bin/bash

# (String log_file, String name, String value, int padding=20) -> log
function ARCH::log() {
    alert ARCH 'in ARCH::log';
    
    local log_file="$1";
    local name="$2";
    local value="$3";    
    local padding="${4:-20}";
    
    # pad the line
    local line=$(printf "$name%$((padding - ${#name}))s$value\n");

    # flatten whitespace
    line=$(UTIL::flatten_text "$line")
    
    echo "$line" >> "$log_file";
}
