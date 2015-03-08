#!/bin/bash

declare -A OPTIONS=();


# (String option_name)
function add_option() {

    local option="$1";

    OPTIONS["$option"]=true;

}

# (String option, ...)
function process_line() {
    
    OPTIONS::on_preprocess "$@";
    
    # process options
    process "$@";
    
    OPTIONS::on_postprocess "$@";
}


# (String option, ...)
function process() {

    local option="$1";
    shift;
        
    if [[ -n "$option" ]] && [[ -n "${OPTIONS[$option]}" ]]; then
        "option_${option}" "$@";
    elif [[ -z "$option" ]]; then
        OPTIONS::on_missing;
    else
        OPTIONS::on_invalid "$option" "$@";
    fi

}


# (...) !! 1
function verify_no_args() {
    
    [[ -n "$@" ]] && terminate 1 "Extra arguments found '$@'"    

}


# (...) | virtual
function OPTIONS::on_preprocess() {
    alert OPTIONS "in preprocess";
}

# (...) | virtual
function OPTIONS::on_postprocess() {
    alert OPTIONS "in postprocess";
}


# () !! 1 | virtual
function OPTIONS::on_missing() {
    terminate 1 "No option supplied";    
}

# (String option, ...) !! 1 | virtual
function OPTIONS::on_invalid() {

    local option="$1";
    shift;

    terminate 1 "Invalid option: $option";
}


# () -> loads option files
function load_options() {    
    local option_glob="$SCRIPT_PATH/options/*";
    local option_file=;
    
    for option_file in $option_glob; do
        [[ "$option_file" == "$option_glob" ]] && break;
        alert OPTIONS "$option_file";
        source "$option_file";
    done
    
    alert OPTIONS "Loaded: (${!OPTIONS[@]})"
}

load_options
