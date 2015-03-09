#!/bin/bash

#debug_on OPTIONS_VARS;

declare VARS_LOADED=;

declare -A VARS=()
trap 'echo ------; declare -A; echo ------' DEBUG

# (String... name, [--as value | --from <command>])
add_option 'set';
function option_set() {

    load_vars;
        
    local -a vars=();
    
    local value='true';   
    
    
    while [[ -n "$1" ]]; do
    
        if [[ "$1" == '--as' ]]; then
            value=$2; 
            shift 2;
            verify_no_args "$@";
        elif [[ "$1" == '--from' ]]; then
            value=$(eval "$2"); 
            shift 2;
            verify_no_args "$@";
        else
            alert OPTIONS_VARS "$1";
            vars+=("$1");
            shift;
        fi                
        
    done
    
    # set all vars to the value
    for name in "${vars[@]}"; do
        alert OPTIONS_VARS "VARS[$name]=$value";
        VARS[$name]="$value";
        #alert OPTIONS_VARS "${VARS[$name]}";                
    done
                        
    save_vars;
    
    list_vars;
}

# (String... name)
add_option 'unset';
function option_unset() {
:
}

# (String... name)
add_option 'var';
function option_var() {
    list_vars "$@";
}

# (String name, ...)
add_option 'on';
function option_on() {
:
}



# () -> VARS < VARS_FILE
function load_vars() {
    alert OPTIONS_VARS "in load_vars";
        
    if [[ -z "$VARS_LOADED" ]]; then
        
        local var_file="$(VARS::var_file)";
        
        local name=;
        while IFS= read -r line || [[ -n $line ]]; do
        
            if [[ -z "$name" ]]; then
                name="$line";
            else
                alert OPTIONS_VARS "VARS[$name]=$line";
                VARS[$name]="$line";
                unset name;
            fi
        
        done < "$var_file";
        
        VARS_LOADED=true;
    fi
}

# () -> VARS > VARS_FILE
function save_vars() {
    alert OPTIONS_VARS "in save_vars";
    
    local var_file="$(VARS::var_file)";
    > "$var_file";
    
    local name=;
    local value=;
    
    for name in "${!VARS[@]}"; do
        value="${VARS[$name]}";
        alert OPTIONS_VARS "VARS[$name]=$value";
        echo "$name" >> "$var_file";
        echo "$value" >> "$var_file";
    done
}

# (String... names)
function list_vars() {
    
    alert OPTIONS_VARS "in list_vars";
    
    local name=;
    local value=;
    
    # no variables
    if [[ -z "${VARS[@]}" ]]; then
        VARS::empty_header;
        
    # print specified variables
    elif [[ -n "$1" ]]; then   
    
        VARS::header;
    
        while [[ -n "$1" ]]; do
            name="$1"; shift;
            value="${VARS[$name]}";
            VARS::display_var "$name" "$value";
        done        
    
    # print all variables
    else        
    
        VARS::header;
        
        for name in "${!VARS[@]}"; do
            value="${VARS[$name]}";
            VARS::display_var "$name" "$value";
        done
        
    fi
}


# virtual | () => String var_file
function VARS::var_file() {
    #alert OPTIONS_VARS "in VARS::var_file"
    echo "/dev/null";
}

# virtual | () -> header
function VARS::empty_header() {
    echo "<no definitions>"
}

# virtual | () -> header
function VARS::header() {
    echo "<variables>"
}

# virtual | (String name, String value) -> var
function VARS::display_var() {
    local name="$1";
    local value="${2:-<not defined>}";
    
    echo " [$name] = $value";
}