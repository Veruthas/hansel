#!/bin/bash

## Implements options for variables (set,unset,vars,on)

DEBUG::off VAR_OPTIONS;


global VAR_OPTIONS_FILE_NAME='vars.dat';

function VAR_OPTIONS::vars_file_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}

function VAR_OPTIONS::vars_file_path() {
    echo "$(VAR_OPTIONS::vars_file_directory)/$VAR_OPTIONS_FILE_NAME";
}


# () => AA vars
function VAR_OPTIONS::load_vars() {
    local vars_file="$(VAR_OPTIONS::vars_file_path)";
    
    VARS::load_vars "$vars_file";
}

# (AA vars) > var_file
function VAR_OPTIONS::save_vars() {
    alert VAR_OPTIONS 'in VAR_OPTIONS::save_vars';
    
    local vars="$1";
    
    local vars_file="$(VAR_OPTIONS::vars_file_path)"; 
    
    
    VARS::save_vars "$vars_file" "$vars";    
}

# (String name) => VAR[name]
function VAR(){
    alert VAR_OPTIONS 'in Var';
    
    local name="$1";
    
    local vars="$(VAR_OPTIONS::load_vars)";
        
    VARS::get_var "$vars" "$name";
}


## OPTIONS

# ([--as <value> | --from <command>], String... name)
OPTIONS::add 'set' 'VAR_OPTIONS::option_set';
function VAR_OPTIONS::option_set() {
    alert VAR_OPTIONS 'in VAR_OPTIONS::option_set';
        
    local value=;
    
    case "$1" in
        --as)
            value="$2";
            shift 2;
        ;;
        --from)
            value="$(eval $2)";
            shift 2;
        ;;
        *)
            value=true;
        ;;
    esac
    
    
    local vars="$(VAR_OPTIONS::load_vars)";
    
    vars=$(VARS::set_vars "$vars" "$value" "$@");
    
    VAR_OPTIONS::save_vars "$vars";    
}

# (String... name) -> unset VARS[name...]
OPTIONS::add 'unset' 'VAR_OPTIONS::option_unset';
function VAR_OPTIONS::option_unset() {
    alert VAR_OPTIONS 'in option_unset';
    
    
    local vars="$(VAR_OPTIONS::load_vars)";
    
    vars=$(VARS::unset_vars "$vars" "$@");
    
    VAR_OPTIONS::save_vars "$vars";    
}

# (String... vars) -> >&1
OPTIONS::add 'vars' 'VAR_OPTIONS::option_vars';
function VAR_OPTIONS::option_vars() {
    alert VAR_OPTIONS 'in VAR_OPTIONS::option_vars';
    
    local vars="$(VAR_OPTIONS::load_vars)";
    
    VARS::list_vars "$vars" "$@";
}


# (<var> ...) -> if var defined ...
OPTIONS::add 'on' 'VAR_OPTIONS::option_on';
function VAR_OPTIONS::option_on() {
    alert VAR_OPTIONS  'in VAR_OPTIONS::option_on'
    
    local name="$1"; shift;        
    
    local var=$(VAR "$name");
    
    [[ -n "$var" ]] && OPTIONS::process "$@";
}

