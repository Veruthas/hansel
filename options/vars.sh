#!/bin/bash

debug_on OPTIONS_VARS;

global -A VARS;

global VARS_LOADED;


# () -> VARS < var_file
function load_vars() {
    alert OPTIONS_VARS 'in load_vars';
}

# () -> >var_file
function save_vars() {
    alert OPTIONS_VARS 'in save_vars';
}

# (String... names) ->  >&1
function list_vars() {
    alert OPTIONS_VARS 'in list_vars';
    
    if (( ${#VARS[@]} == 0 )); then
        VARS::show_empty;
    else
        VARS::show_header;
        
        local name=;
        
        if [[ -n "$1" ]]; then
            while [[ -n "$1" ]]; do
                name="$1"; shift;
                list_var "$name";
            done
        else
            for name in "${!VARS[@]}"; do
                list_var "$name";
            done
        fi
    fi
        
}

# (String name) -> show_var name [name] >&1
function list_var() {
    alert OPTIONS_VARS 'in list_var';
    local name="$1";
    local value="${VARS[$1]}";
    VARS::show_var "$name" "$value";
}

# virtual | () -> >&1
function VARS::show_empty() {
    alert OPTIONS_VARS 'in VARS::show_empty';
    
    echo "<no definitions>";
}

# virtual | () -> >&1
function VARS::show_header() {
    alert OPTIONS_VARS 'in VARS::show_header';
    
    echo "<variables>";
}

# virtual | (String name, String value) -> >&1
function VARS::show_var() {
    alert OPTIONS_VARS 'in VARS::show_var';
    
    local name="$1";
    local value="${2:-<not defined>}";
    
    echo " [$name] = $value";
}

# virtual | () => var_file
function VARS::var_file() {
    alert OPTIONS_VARS 'in VARS::var_file';
    echo "/dev/null";
}