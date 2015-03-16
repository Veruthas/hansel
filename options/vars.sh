#!/bin/bash

## Implements options for variables (set,unset,vars,on)

DEBUG::off OPTIONS_VARS;

global -A VARS;

global VARS_LOADED;


# ([--as <value> | --from <command>], String... name) -> VARS[name...]=true|from|as
OPTIONS::add 'set';
function OPTIONS::set() {

    alert OPTIONS_VARS 'in option_set';
    
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
    
    alert OPTIONS_VARS "value is <$value>";
    
    while [[ -n "$1" ]]; do
    
        local name="$1";
        shift;
        
        VARS["$name"]="$value";
        
        alert OPTIONS_VARS "setting [$name] to <$value>";
    
    done
    
    VARS::save_vars;
    VARS::list_vars;
}

# (String... name) -> unset VARS[name...]
OPTIONS::add 'unset';
function OPTIONS::unset() {

    alert OPTIONS_VARS 'in option_unset';
    
    VARS::load_vars;
    
    while [[ -n "$1" ]]; do
    
        local name="$1";
        shift;
        
        alert OPTIONS_VARS "unsetting $name; old value ${VARS[$name]}";
        
        unset VARS["$name"];
    
    done
    
    
    VARS::save_vars;
    VARS::list_vars;
}

# (String... vars) -> >&1
OPTIONS::add 'vars';
function OPTIONS::vars() {
    alert OPTIONS_VARS 'in option_vars';
    
    VARS::load_vars;
    
    VARS::list_vars "$@";
}


# (<var> ...) -> if var defined ...
OPTIONS::add 'on';
function OPTIONS::on() {
    alert OPTIONS_VARS 'in option_on'
    
    VARS::load_vars;
    
    local name="$1";
    shift;
    
    if [[ -n "${VARS[$name]}" ]]; then
        OPTIONS::process "$@";
    fi
}



# () -> VARS < var_file
function VARS::load_vars() {
    alert OPTIONS_VARS 'in load_vars';
    
    if [[ -z "$VARS_LOADED" ]]; then
        
        local var_file="$(VARS::var_file)";        
        [[ ! -e "$var_file" ]] && > "$var_file";
        
        local name=;
        
        while read -r line; do
            
            # if a blank line is in the file
            if [[ -z "$line" ]]; then
                unset name;
            else
                if [[ -z "$name" ]]; then
                    name="$(expand $line)";
                else            
                    alert OPTIONS_VARS "VARS[$name]=$line";
                    VARS["$name"]="$(expand $line)";
                    unset name;
                fi
            fi
        
        done < "$var_file";
        
        
        VARS_LOADED=true;
    fi
}

# () -> >var_file
function VARS::save_vars() {
    alert OPTIONS_VARS 'in save_vars';
    
    local var_file="$(VARS::var_file)";    
    > "$var_file";
    
    local name=;
    local value=;
    
    for name in "${!VARS[@]}"; do
        alert OPTIONS_VARS "subscript $name";
        value="${VARS[$name]}";
        echo $(flatten "$name")  >> "$var_file";
        echo $(flatten "$value") >> "$var_file";
    done
        
    VARS_LOADED=true;
}

# (String... names) ->  >&1
function VARS::list_vars() {
    alert OPTIONS_VARS 'in list_vars';
    
    if (( ${#VARS[@]} == 0 )); then
        VARS::show_empty;
    else
        VARS::show_header;
        
        local name=;
        
        if [[ -n "$1" ]]; then
            while [[ -n "$1" ]]; do
                name="$1"; shift;
                VARS::list_var "$name";
            done
        else
            for name in "${!VARS[@]}"; do
                VARS::list_var "$name";
            done
        fi
    fi
        
}

# (String name) -> show_var name [name] >&1
function VARS::list_var() {
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
    
    echo " [$name] = '$value'";
}

# virtual | () => var_file
function VARS::var_file() {
    alert OPTIONS_VARS 'in VARS::var_file';
    echo "/dev/null";
}


OPTIONS::add_preprocess "VARS::load_vars";
