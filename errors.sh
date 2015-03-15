#!/bin/bash

## Implements debug/error system

#region DEBUG

global DEBUG_HEADER;
global DEBUG_FLAG_HEADER;

global DEBUG_FILE;
global DEBUG_SILENT;

global -A DEBUG_FLAGS=([-]=true);

function DEBUG::print_args() {
    echo PRINTING ARGS >&2;
    for arg in "$@"; do 
        echo $arg >&2;
    done
}

# (String flag, String message) > message
# - is the default flag
function alert() {     
    local message=;
    local flag=;
    
    if [[ -z "$2" ]]; then
        flag='-';         
        message="$1";        
    else       
        flag="$1";        
        message="$2";        
    fi
        
    alert_echo "$flag" "$message";
}

# (bool condition, String flag, String true, String false) ?> message
function check() {
    local condition="$1";    
    shift; 
    
    local flag=;
    local true_msg=;
    local false_msg=;
    
    if (( $# < 3 )); then
        flag='-';
    else
        flag="$1"; shift;
    fi
    
    true_msg="$1";
    false_msg="$2";
        
    eval "$condition";
    
    if [[ "$?" == '0' ]]; then
        alert_echo "$flag" "$true_msg"
    else
        alert_echo "$flag" "$false_msg";
    fi
}

# (String flag, String message) > message
function alert_echo() {
    
    local flag="$1";
    
    local message="$2";
    
    if [[ -n "${DEBUG_FLAGS[$flag]}" ]]; then        
        message="$(make_debug_header $flag)'$message'";

        [[ -z "$DEBUG_SILENT" ]] && echo "$message" >&2;        
        [[ -n "$DEBUG_FILE" ]] && echo "$message" >> "$DEBUG_FILE";

    fi
}

# ([flag]) -> DEBUG_FLAG[$flag]=true
function debug_on() {
    local flag="${1:--}";
    
    DEBUG_FLAGS[$flag]=true;
}

# ([flag]) -> DEBUG_FLAG[$flag]=true
function debug_off() {
    local flag=${1:--};
    
    unset DEBUG_FLAGS[$flag];
}

# () -> DEBUG_SILENT=true
function debug_silent() {
    DEBUG_SILENT=true;
}

# () -> DEBUG_SILENT=
function debug_noisy() {
    unset DEBUG_SILENT;
}


# (String header) -> DEBUG_HEADER=header
# %flag% => where flag header should go
function debug_header() {
    DEBUG_HEADER="$@";
}

# (String header) -> DEBUG_FLAG_HEADER=header
# Conditional if flag invoked
# %flag% => where flag should go
function debug_flag_header() {
    DEBUG_FLAG_HEADER="$@";
}

# (String flag) => String header
function make_debug_header() {
    
    local flag="$1";
    local flag_mark="%flag%"    
    local flag_header="";
    
    [[ "$flag" != '-' ]] && flag_header="${DEBUG_FLAG_HEADER//$flag_mark/$flag}";
    
    local header="${DEBUG_HEADER//$flag_mark/$flag_header}";
    
    echo "$header";
}

# () -> debug_header,debug_flag_header
function debug_simple_header() {
    debug_header 'debug%flag%: ';
    debug_flag_header ' <%flag%>';
}


# (String file) -> DEBUG_File=file
function debug_file() {
    local file="$@";
    
    DEBUG_FILE="$file";
}


#endregion

#region ERRORS

declare ERROR_HEADER=;

declare ERROR_SILENT=;
declare ERROR_FILE=;

declare ERROR_ID=;
declare ERROR_MESSAGE=;

# (int error, String message, bool? quit)
function error() {
    
    ERROR_ID="${1:-0}";
    ERROR_MESSAGE="$2";
    local quit="$3";
    
    local id_mark='%id%';    
    local header="${ERROR_HEADER//$id_mark/$ERROR_ID}";
    
    local message="$header$ERROR_MESSAGE";
    
    [[ -z "$ERROR_SILENT" ]] && echo "$message" >&2;
    [[ -n "$ERROR_FILE" ]] && echo $message >> "$ERROR_FILE";
    
    
    [[ -z "$quit" ]] && return "$ERROR_ID" || exit "$ERROR_ID";
}

# (int error, String message)
function terminate() {

    local error="$1";
    local message="$2";
    error "$error" "$message" "true";
}

# (bool condition, int error, String message)
function assert() {
    local condition="$1";
    shift;
    
    eval "$condition";
    [[ "$?" != '0' ]] && terminate "$@";
}

# () -> ERROR_SILET=true
function error_silent() {
    ERROR_SILENT=true;
}

# () -> unset ERROR_SILENT
function error_noisy() {
    unset ERROR_SILENT;
}


# (String file) -> ERROR_FILE=file
function error_file() {
    local file="$@";
    
    ERROR_FILE="$file";
}

# (String header) -> ERROR_HEADER=header
# %id% -> ERROR ID 
function error_header() {    
    
    local header="$1";
    
    ERROR_HEADER="$header";
}

function error_simple_header() {
    error_header "error: "
}

#endregion

#region SUPPLIED_ERRORS

global ERROR_MISSING_ARG_ID=1;

# (String arg_name, bool? quit)
function ERROR::missing_arg() {
    local arg_name="$1";
    local quit="$2";
    
    local message="missing argument <$arg_name>";
    
    error "$ERROR_MISSING_ARG_ID" "$message" "$quit";
}

global ERROR_PATH_NO_EXIST=2;

# (String path, bool? quit)
function ERROR::path_no_exist() {
    local path="$1";
    local quit="$2";
    
    local message="path <$path> does not exist";
    
    error "$ERROR_PATH_NO_EXIST" "$message" "$quit";
}

#endregion
