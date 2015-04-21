#!/bin/bash

DEBUG::off SETTINGS_OPTIONS

# ((var | cache), String path)
OPTIONS::add 'path' "SETTINGS_OPTIONS::path";
function SETTINGS_OPTIONS::path() {
    alert 'in SETTINGS_OPTIONS::path';
    
    local target="$1";
    
    local path="$2";
    
    if [[ "$target" != 'var' ]] && [[ "$target" != 'cache' ]]; then
        throw 1 "Invalid target '$target'";
        return $?;
    fi
    
    SETTINGS::set_${target}_path "$2";
}