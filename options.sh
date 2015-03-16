#!/bin/bash

## Implements Options API

DEBUG::off OPTIONS

global -A OPTIONS;


global -a OPTIONS_PREPROCESS;

global -a OPTIONS_POSTPROCESS;


# (String option_name)
function OPTIONS::add() {

    local option="$1";

    alert OPTIONS "adding <$option>";
    
    OPTIONS["$option"]=true;

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
        "OPTIONS::${option}" "$@";
    elif [[ -z "$option" ]]; then
        OPTIONS::on_missing;
    else
        OPTIONS::on_invalid "$option" "$@";
    fi
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


# () -> loads option files
function OPTIONS::load() {    
    local option_glob="$SCRIPT_PATH/options/*";
    local option_file=;
    
    for option_file in $option_glob; do
        [[ "$option_file" == "$option_glob" ]] && break;
        alert OPTIONS "loading <$(basename $option_file)> @ <$(dirname $option_file)>";
        source "$option_file";
        alert OPTIONS ' ';                
    done
    
    
    # HACK: Only way it will process this as one argument
    local added="added: (${!OPTIONS[@]})";
    alert OPTIONS "$added"
}

OPTIONS::load;
