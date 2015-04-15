#!/bin/bash

## Implements options for variables (set,unset,vars,on)

DEBUG::off VARS_OPTIONS;


global -A VARS;

global VARS_LOADED;


# ([--as <value> | --from <command>], String... name) -> VARS[name...]=true|from|as
OPTIONS::add 'set' 'VARS::option_set';
function VARS::option_set() {
    alert VARS 'in VARS::option_set';
    
    VARS::load_vars;
    
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
    
    alert VARS "value is <$value>";
    
    while [[ -n "$1" ]]; do
    
        local name="$1";
        shift;
        
        VARS["$name"]="$value";
        
        alert VARS "setting [$name] to <$value>";
    
    done
    
    VARS::save_vars;
    VARS::list_vars;
}

# (String... name) -> unset VARS[name...]
OPTIONS::add 'unset' 'VARS::option_unset';
function VARS::option_unset() {

    alert VARS 'in option_unset';
    
    VARS::load_vars;
    
    while [[ -n "$1" ]]; do
    
        local name="$1";
        shift;
        
        alert VARS "unsetting $name; old value ${VARS[$name]}";
        
        unset VARS["$name"];
    
    done
    
    
    VARS::save_vars;
    VARS::list_vars;
}

# (String... vars) -> >&1
OPTIONS::add 'vars' 'VARS::option_vars';
function VARS::option_vars() {
    alert VARS 'in option_vars';
    
    VARS::load_vars;
    
    VARS::list_vars "$@";
}


# (<var> ...) -> if var defined ...
OPTIONS::add 'on' 'VARS::option_on';
function VARS::option_on() {
    alert VARS 'in option_on'
    
    VARS::load_vars;
    
    local name="$1";
    shift;
    
    if [[ -n "${VARS[$name]}" ]]; then
        OPTIONS::process "$@";
    fi
}


# ('--default' String, '--max' int, String... items) -> prompt? -> VARS[choices...]=true
OPTIONS::add 'choose' 'VARS::option_choose';
function VARS::option_choose() {
    alert VARS 'in VARS::option_choose';
    
    throw 1 "Not implemented yet.";
    
    return
    
    local max=-1;
    
    local default=;       
        
    if [[ "$1" == '--default' ]]; then
        default="$2"                
        shift 2;                
    fi
      
    local -a items=("$@");
    
    # display items
    local i=0;
    for item in "${items[@]}"; do
        echo "$i: $item";
        ((i++));
    done
    
    # TODO: Slove
    read -e -p "Enter choices: " -i "$default" choices;
        
    ERROR::clear;
    
    local -a chosen=($(UTIL::expand_numbers $choices));
    
    if ERRED; then
        
        throw; return $?;
    fi
    
    echo ${#choices[@]};
}
