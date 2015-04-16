#!/bin/bash

## Implements Options API

DEBUG::off OPTIONS

global -A OPTIONS;


global -a OPTIONS_PREPROCESS;

global -a OPTIONS_POSTPROCESS;


# (String option_name, String option funciton)
function OPTIONS::add() {

    local option="$1";
    local option_function="$2";
    
    alert OPTIONS "adding <$option>";
    
    OPTIONS["$option"]="$option_function";
}

# (String option, ...)
function OPTIONS::process_line() {
    
    OPTIONS::preprocess "$@";
        
    # process options    
    OPTIONS::process "$@";
    
    OPTIONS::postprocess "$@";
}



# (String option, ...)
function OPTIONS::process() {

    local option="$1";
    shift;
    
    if [[ -n "$option" ]] && [[ -n "${OPTIONS[$option]}" ]]; then
        "${OPTIONS[$option]}" "$@";        
        OPTIONS::verify_no_errors;
        
    elif [[ -z "$option" ]]; then
        OPTIONS::on_missing;
        
    else
        OPTIONS::on_invalid "$option" "$@";
        
    fi
}


# () !!
function OPTIONS::verify_no_errors() {
    ERRED && terminate;
}

# (...) !! 1
function OPTIONS::verify_no_args() {
    
    [[ -n "$@" ]] && terminate 1 "Extra arguments found '$@'"    

}


# (String function)
function OPTIONS::add_preprocess() {
    alert OPTIONS "in OPTIONS::add_preprocess";

    local func="$1";
    
    OPTIONS_PREPROCESS+=("$func");
}

# (String function)
function OPTIONS::add_postprocess() {
    alert OPTIONS "in OPTIONS::add_postprocess";
    
    local func="$1";
    
    OPTIONS_POSTPROCESS+=("$func");
}


# (...) 
function OPTIONS::preprocess() {
    alert OPTIONS "in OPTIONS::preprocess";

    for func in "${OPTIONS_PREPROCESS[@]}"; do
        $func "$@";
    done
}

# (...)
function OPTIONS::postprocess() {
    alert OPTIONS "in OPTIONS::postprocess";

    for func in "${OPTIONS_POSTPROCESS[@]}"; do
        $func "$@";
    done 
}



# virtual | () !! 1
function OPTIONS::on_missing() {
    terminate 1 "no option given";    
}

# virtual | (String option, ...) !! 2
function OPTIONS::on_invalid() {

    local option="$1";
    shift;

    terminate 2 "invalid option: $option";
}
