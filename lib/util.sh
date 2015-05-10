#!/bin/bash

## Basic utility functions

[[ -z "$UTIL" ]] && declare UTIL=true || return;

alias global='declare -g';



# (String text) => String flattened 
function UTIL::flatten_text() {
    local text="$@"
    text="${@//$'\n'/\\n}";
    text="${text//$'\t'/\\t}";
    echo "$text"
}

# (String flattened) => String text
function UTIL::expand_text() {    
    echo -e "$@";
}


# (int number) -> 0/1 
function UTIL::is_number() {
    
    [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1;
}

# (int-int) => 0/1
function UTIL::is_range() {
    [[ "$1" =~ ^[0-9]+-[0-9]+$ ]] && return 0 || return 1;
}


# (int-int) => int...
function UTIL::expand_range() {
    local range="$1";
 
    ! UTIL::is_range "$range" && return 1;
    
    local start; local end;
    
    IFS='-' read start end <<< "$range";
    
    local result="";

    if (( start > end )); then
        while ((end <= start)); do
            result+="$start ";
            ((start--));
        done
    else
        while ((start <= end)); do
            result+="$start ";
            ((start++));
        done
    fi            
    
    echo "$result";
}   

# (range... int...) => int...
function UTIL::expand_numbers() {
    local -A list=();
        
    while (( $# > 0 )); do        
        
        if UTIL::is_number "$1"; then
            list[$1]=$1;
            
        elif UTIL::is_range "$1"; then
            local i=; for i in $(UTIL::expand_range $1); do                
                list[$i]=$i;                
            done
            
        else            
            error 1 "Invalid arg '$1'"; return $?;
            
        fi
        
        shift;
        
    done
    
    echo "${list[@]}";
}


# (int a, int b) -> a < b
function UTIL::less_than() {
    (( $1 < $2 )) && return 0 || return 1;
}

# (int a, int b) -> a > b
function UTIL::greater_than() {
    (( $1 > $2 )) && return 0 || return 1;
}


# (String comparer, String... list) => String... list
function UTIL::selection_sort() {
    local comparer="$1"; shift;
    
    local -a list=("$@");
    
    local i; for (( i = 0; i < ${#list[@]}; i++ )); do
        
        local next=$i;
        
        local j; for (( j = i; j < ${#list[@]}; j++ )); do
             $comparer "${list[$next]}" "${list[$j]}" && next=$j;
        done
        
        local temp=${list[$i]};
        list[$i]=${list[$next]};
        list[$next]=$temp;
        
    done
    
    echo ${list[@]};
}

# (function url_path) -> 1/0
function UTIL::url_path_exists() {
    # Will not work with bad url's because verizon's page comes up every time :\
    local url_path="$1";
    wget --quiet --spider $url_path && return 0 || return 1;
}


# () => 32|64
function UTIL::get_system_bits() {
    getconf LONG_BIT;
}

# () -> 0/1
function IS_ROOT() {
    (( EUID == 0 )) && return 0 || return 1;
}

# () -> 0/1
function IS_USER() {
    (( EUID != 0 )) && return 0 || return 1;
}


# TODO: ADD UTIL BACKUP METHOD (add a .# suffix => a.txt -> a.txt.0 ...)
