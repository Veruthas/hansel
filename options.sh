#!/bin/bash

declare -A OPTIONS=();


# (String option_name)
function add_option() {

    local option="$1";

    OPTIONS["$option"] = true;

}

# (String option, ...)
function process() {

    local option="$1";        
    shift;
        
    if [[ -n "$option" ]] && [[ -n "${OPTIONS[$option]}" ]]; then
        "process_${option}" "$@";
    elif [[ -z "$option" ]]; then
        no_option;
    else
        invalid_option "$option" "$@";
    fi

}

# () !! 1
function no_option() {
    echo "No option supplied" >&2;
    exit 1;
}

# (String option, ...) !! 1
function invalid_option() {

    local option="$1";
    shift;

    echo "Invalid option: $option" >&2;
    exit 1;
}


# (...) !! 1
function verify_no_args() {
    
    if [[ -n "$@" ]]; then
        echo "Extra arguments found: '$@'" >&2;
        exit 1;
    fi
    
}