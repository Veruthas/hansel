#!/bin/bash

## SUMMARY: Implements variables functions (set,unset,vars,on)
## DEPENDS: lib/util.sh

DEBUG::off VARS;


# (String filename) => AA vars < filename
function VARS::load_vars() {
    alert VARS 'in VARS::load_vars';
    
    local filename="$1";
    
    [[ ! -e "$filename" ]] && echo '()' && return;
    
    local -A vars=();    
    local name=;    
    
    while read -r line; do
        
        # if a blank line is in the file
        if [[ -z "$line" ]]; then
            unset name;
        else
            if [[ -z "$name" ]]; then
                name="$(UTIL::expand_text $line)";
            else            
                alert VARS "vars[$name]=$line";
                vars["$name"]="$(UTIL::expand_text $line)"
                unset name;
            fi
        fi
    
    done < "$filename";
    
    local result="$(declare -p vars)"
    
    echo "${result#*=}";
}

# (String filename, AA vars) > filename

function VARS::save_vars() {
    alert VARS 'in VARS::save_vars';
    
    local filename="$1";
    eval "local -A vars=$2";
    
    > "$filename";
    
    local name=;
    local value=;
    
    for name in "${!vars[@]}"; do
        alert vars "subscript $name";
        value="${vars[$name]}";
        echo $(UTIL::flatten_text "$name")  >> "$filename";
        echo $(UTIL::flatten_text "$value") >> "$filename";
    done        
}


# (AA vars, String value, String... name) => AA vars
function VARS::set_vars() {
    alert VARS "in VARS::set_var";
    
    eval "local -A vars=$1";
    
    local value="$2";
    
    shift 2;
    
    while (( $# > 0 )); do
        alert VARS "[$1] = {$value}";
        vars["$1"]="$value";
        shift;
    done
    
    local result="$(declare -p vars)";
    
    echo "${result#*=}";
}

# (AA vars, String... name) => AA vars
function VARS::unset_vars() {
    alert VARS "in VARS::unset_var";
    
    eval "local -A vars=$1"; shift;
        
    while (( $# > 0 )); do        
        unset vars["$1"];
        shift;
    done
    
    local result="$(declare -p vars)";
    
    echo "${result#*=}";
}


# (AA vars, String name) => var
function VARS::get_var() {
    alert VARS "in VARS::get_var";
    
    eval "local -A vars=$1";
    
    local name="$2";
    
    echo "${vars[$name]}";
}


# (AA vars, String... names) => formatted_vars
function VARS::list_vars() {
    alert VARS 'in VARS::list_vars';
    
    eval "local -A vars=$1";
    shift;    
    
    if (( ${#vars[@]} == 0 )); then
        VARS::format_empty;
    else
        VARS::format_header;
        
        local name=;
        local value=;
        
        if (( $# > 0 )); then
            while [[ -n "$1" ]]; do
                name="$1"; shift;
                value="${vars[$name]}";
                VARS::format_var "$name" "$value";
            done
        else
            for name in "${!vars[@]}"; do                
                value="${vars[$name]}";
                VARS::format_var "$name" "$value";
            done
        fi
    fi
        
}

# virtual | () -> >&1
function VARS::format_empty() {
    alert VARS 'in VARS::format_empty';
    
    echo "<no definitions>";
}

# virtual | () -> >&1
function VARS::format_header() {
    alert VARS 'in VARS::format_header';
    
    echo "<variables>";
}

# virtual | (String name, String value) -> >&1
function VARS::format_var() {
    alert VARS 'in VARS::format_var';
    
    local name="$1";
    local value="${2:-<not defined>}";
    
    echo " [$name] = '$value'";
}

