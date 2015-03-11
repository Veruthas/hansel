#!/bin/bash

## Implements options for variables (set,unset,vars,on)

debug_off OPTIONS_VARS;

global -A VARS;

global VARS_LOADED;


# ([--as <value> | --from <command>], String... name) -> VARS[name...]=true|from|as
add_option 'set';
function option_set() {
    alert OPTIONS_VARS 'in option_set';
    
    load_vars;
    
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
    
    save_vars;
    list_vars;
}

# (String... name) -> unset VARS[name...]
add_option 'unset';
function option_unset() {
    alert OPTIONS_VARS 'in option_unset';
    
    load_vars;
    
    while [[ -n "$1" ]]; do
    
        local name="$1";
        shift;
        
        alert OPTIONS_VARS "unsetting $name; old value ${VARS[$name]}";
        
        unset VARS["$name"];
    
    done
    
    
    save_vars;
    list_vars;
}

# (String... vars) -> >&1
add_option 'vars';
function option_vars() {
    alert OPTIONS_VARS 'in option_vars';
    
    load_vars;
    
    list_vars "$@";
}


# (<var> ...) -> if var defined ...
add_option 'on';
function option_on() {
    alert OPTIONS_VARS 'in option_on'
    
    load_vars;
    
    local name="$1";
    shift;
    
    if [[ -n "${VARS[$name]}" ]]; then
        process "$@";
    fi
}


# () -> VARS < var_file
function load_vars() {
    alert OPTIONS_VARS 'in load_vars';
    
    if [[ -z "$VARS_LOADED" ]]; then
        
        local var_file="$(VARS::var_file)";        
        [[ ! -e "$var_file" ]] && > "$var_file";
        
        local name=;
        
        while read -r line; do
            
            # if a blank line is in the file
            # TODO: support multi-line values
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
function save_vars() {
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
    
    echo " [$name] = '$value'";
}

# virtual | () => var_file
function VARS::var_file() {
    alert OPTIONS_VARS 'in VARS::var_file';
    echo "/dev/null";
}