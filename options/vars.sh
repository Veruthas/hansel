#!/bin/bash

## Implements options for variables (set,unset,vars,on)

DEBUG::off VARS;

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


# () -> VARS < var_file
function VARS::load_vars() {
    alert VARS 'in load_vars';
    
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
                    name="$(UTIL::expand_text $line)";
                else            
                    alert VARS "VARS[$name]=$line";
                    VARS["$name"]="$(UTIL::expand_text $line)";
                    unset name;
                fi
            fi
        
        done < "$var_file";
        
        
        VARS_LOADED=true;
    fi
}

# () -> >var_file
function VARS::save_vars() {
    alert VARS 'in save_vars';
    
    local var_file="$(VARS::var_file)";    
    > "$var_file";
    
    local name=;
    local value=;
    
    for name in "${!VARS[@]}"; do
        alert VARS "subscript $name";
        value="${VARS[$name]}";
        echo $(UTIL::flatten_text "$name")  >> "$var_file";
        echo $(UTIL::flatten_text "$value") >> "$var_file";
    done
        
    VARS_LOADED=true;
}

# (String... names) ->  >&1
function VARS::list_vars() {
    alert VARS 'in list_vars';
    
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
    alert VARS 'in list_var';
    local name="$1";
    local value="${VARS[$1]}";
    VARS::show_var "$name" "$value";
}


# (String name)
function VAR(){
    alert VARS 'in VAR';
    
    VARS::load_vars;
    
    local name="$1";    
    
    echo "${VARS[$name]}";
}


# virtual | () -> >&1
function VARS::show_empty() {
    alert VARS 'in VARS::show_empty';
    
    echo "<no definitions>";
}

# virtual | () -> >&1
function VARS::show_header() {
    alert VARS 'in VARS::show_header';
    
    echo "<variables>";
}

# virtual | (String name, String value) -> >&1
function VARS::show_var() {
    alert VARS 'in VARS::show_var';
    
    local name="$1";
    local value="${2:-<not defined>}";
    
    echo " [$name] = '$value'";
}


# virtual | () => var_file
function VARS::var_file() {
    alert VARS 'in VARS::var_file';
    echo "$HOME/.hansel/vars";
}

