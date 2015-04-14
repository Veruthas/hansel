#!/bin/bash

## Implements debug/error system

[[ -z "$ERRORS" ]] && declare ERRORS=true || return;

#region DEBUG

global DEBUG_HEADER;
global DEBUG_FLAG_HEADER;

global DEBUG_FILE;
global DEBUG_SILENT;

global -A DEBUG_FLAGS=();


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
        
    DEBUG::alert_echo "$flag" "$message";
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
        DEBUG::alert_echo "$flag" "$true_msg"
    else
        DEBUG::alert_echo "$flag" "$false_msg";
    fi
}

# (String flag, String message) > message
function DEBUG::alert_echo() {
    
    if DEBUGGING; then
        local flag="$1";
        
        local message="$2";
        
        if [[ -n "${DEBUG_FLAGS[$flag]}" ]]; then        
            message="$(DEBUG::make_debug_header $flag)'$message'";

            [[ -z "$DEBUG_SILENT" ]] && echo "$message" >&2;        
            [[ -n "$DEBUG_FILE" ]] && echo "$message" >> "$DEBUG_FILE";

        fi
    fi;
}

# (flag?) -> DEBUG_FLAGS[-]==true
function DEBUGGING() {
    local flag="${1:--}";
    [[ -n "${DEBUG_FLAGS["$flag"]}" ]] && return 0 || return 1;
}

# ([flag]) -> DEBUG_FLAG[$flag]=true
function DEBUG::on() {
    local flag="${1:--}";
    
    DEBUG_FLAGS[$flag]=true;
}

# ([flag]) -> DEBUG_FLAG[$flag]=true
function DEBUG::off() {
    local flag=${1:--};
    
    unset DEBUG_FLAGS[$flag];
}

# () -> DEBUG_SILENT=true
function DEBUG::silent() {
    DEBUG_SILENT=true;
}

# () -> DEBUG_SILENT=
function DEBUG::noisy() {
    unset DEBUG_SILENT;
}


# (String header) -> DEBUG_HEADER=header
# %flag% => where flag header should go
function DEBUG::set_header() {
    DEBUG_HEADER="$@";
}

# (String header) -> DEBUG_FLAG_HEADER=header
# Conditional if flag invoked
# %flag% => where flag should go
function DEBUG::set_flag_header() {
    DEBUG_FLAG_HEADER="$@";
}

# (String flag) => String header
function DEBUG::make_debug_header() {
    
    local flag="$1";
    local flag_mark="%flag%"    
    local flag_header="";
    
    [[ "$flag" != '-' ]] && flag_header="${DEBUG_FLAG_HEADER//$flag_mark/$flag}";
    
    local header="${DEBUG_HEADER//$flag_mark/$flag_header}";
    
    echo "$header";
}

# () -> debug_header,debug_flag_header
function DEBUG::set_simple_header() {
    DEBUG::set_header 'debug%flag%: ';
    DEBUG::set_flag_header ' <%flag%>';
}


# (String file) -> DEBUG_FILE=file
function DEBUG::set_file() {
    local file="$@";
    
    DEBUG_FILE="$file";
}


#endregion

#region ERRORS

global ERROR_HEADER=;

global ERROR_SILENT=;
global ERROR_FILE=;

global ERROR_ID=;
global ERROR_MESSAGE=;


# (int error, String message, String... args)
function error() {
    [[ -n "$@" ]] && ERROR::set_error "$@";
    echo "'$@'" >&2
    return "$ERROR_ID";
}

# (int error, String message, String... args)
function throw() {
    
    [[ -n "$@" ]] && ERROR::set_error "$@";
    
    ERROR::display;    
    
    return "$ERROR_ID";
}


# ([int error, String message, String... args]) -> error
function quit() {
    # To silently quit an already thrown error
    [[ -n "$@" ]] && error "$@";
    
    exit "$ERROR_ID";
}

# ([int error, String message, String... args]) -> throw
function terminate() {

    [[ -n "$@" ]] && throw "$@";
    
    exit "$ERROR_ID";
}


# (bool condition, int error, String message, String... args) -> terminate
function assert() {
    local condition="$1";
    shift;
    
    eval "$condition";
    [[ "$?" != '0' ]] && terminate "$@";
}

function ERRED() {
    (( ERROR_ID != 0 )) && return 0 || return 1;
}

# (int id, String msg, String... args) -> ERROR_ID, ERROR_MSG
function ERROR::set_error() {
    local id="$1";
    local message="$2";
    shift 2;
    
    ERROR_ID="${id:-0}";
    ERROR_MESSAGE=$(printf "$message" "$@");
}

# ()
function ERROR::clear() {
    ERROR_ID=0;
    ERROR_MESSAGE=;
}

# () -> errors >&2
function ERROR::display() {

    local id_mark='%id%';    
    local header="${ERROR_HEADER//$id_mark/$ERROR_ID}";
    
    local message="$header$ERROR_MESSAGE";
    
    
    [[ -z "$ERROR_SILENT" ]] && echo "$message" >&2;
    [[ -n "$ERROR_FILE" ]] && echo $message >> "$ERROR_FILE";
}


# () -> ERROR_SILET=true
function ERROR::silent() {
    ERROR_SILENT=true;
}

# () -> unset ERROR_SILENT
function ERROR::noisy() {
    unset ERROR_SILENT;
}


# (String file) -> ERROR_FILE=file
function ERROR::set_file() {
    local file="$@";
    
    ERROR_FILE="$file";
}

# (String header) -> ERROR_HEADER=header
# %id% -> ERROR ID 
function ERROR::set_header() {    
    
    local header="$1";
    
    ERROR_HEADER="$header";
}

function ERROR::set_simple_header() {
    ERROR::set_header "error: "
}

#endregion

#region SUPPLIED_ERRORS

global ERROR_MISSING_ARG_ID=1;

# (String arg_name, bool throw)
function ERROR::missing_arg() {
    local arg_name="$1";
    local throw="$2";
    
    local message="missing argument <$arg_name>";
    
    error "$ERROR_MISSING_ARG_ID" "$message";
    
    [[ -n "$throw" ]] && throw;
    
    return "$ERROR_ID";
}

global ERROR_PATH_NO_EXIST=2;

# (String path, bool throw)
function ERROR::path_no_exist() {
    local path="$1";
    local throw="$2";
    
    local message="path <$path> does not exist";
    
    error "$ERROR_PATH_NO_EXIST" "$message";
    
    [[ -n "$throw" ]] && throw;
    
    return "$ERROR_ID";
}

global ERROR_FILE_NO_EXIST=3;

# (String file, bool throw)
function ERROR::file_no_exist() {
    local file="$1";
    local throw="$2";
    
    local message="file <$file> does not exist";
    
    error "$ERROR_FILE_NO_EXIST" "$message";
    
    [[ -n "$throw" ]] && throw;
    
    return "$ERROR_ID";
}

#endregion
