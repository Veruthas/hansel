#!/bin/bash

## SUMMARY: Implements variables functions (set,unset,vars,on)
## DEPENDS: lib/util.sh

DEBUG::off VARS;


global VARS_FILE_NAME="vars.dat";

# virtual () => var_directory
function VARS::var_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => var_file
function VARS::var_file() {
    echo "$(VARS::var_directory)/$VARS_FILE_NAME";
}



# () -> VARS < var_file
function VARS::load_vars() {
    alert VARS 'in VARS::load_vars';
    
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
    alert VARS 'in VARS::save_vars';
    
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
    alert VARS 'in VARS::list_vars';
    
    if (( ${#VARS[@]} == 0 )); then
        VARS::format_empty;
    else
        VARS::format_header;
        
        local name=;
        
        if [[ -n "$1" ]]; then
            while [[ -n "$1" ]]; do
                name="$1"; shift;
                VARS::display_var "$name";
            done
        else
            for name in "${!VARS[@]}"; do
                VARS::display_var "$name";
            done
        fi
    fi
        
}

# (String name) -> show_var name [name] >&1
function VARS::display_var() {
    alert VARS 'in VARS::display_var';
    
    local name="$1";
    
    local value="${VARS[$1]}";
    
    VARS::format_var "$name" "$value";
}


# (String name)
function VAR(){
    alert VARS 'in VAR';
    
    VARS::load_vars;
    
    local name="$1";    
    
    echo "${VARS[$name]}";
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

