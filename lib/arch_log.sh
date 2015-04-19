#!/bin/bash

# (String log_file, String category) -> simple_log
function ARCH::log_category() {
    alert ARCH 'in ARCH::log_category';
    
    local log_file="$1";
    local name="$2";
    
    simple_log "$log_file" "category" "$name";
}

# (String log_file, String type, String value) -> simple_log
function ARCH::simple_log() {
    alert ARCH 'in ARCH::simple_log';
    
    local log_file="$1";
    local type="$2";
    local value="$3";    
    
    echo -e "$type\t$value" >> "$log_file";
}
