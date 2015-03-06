#!/bin/bash

declare LOG_FILE="/dev/null";

declare LOG_DATA=;

declare LOGGING_ENABLED=;

# If set, will not log even if loggin is enabled.
declare LOGGING_IGNORED=;



# (String log_file)
function set_log_file() {    
    LOG_FILE="$1";
}

# (String log_data)
function set_log_data() {
    LOG_DATA="$1";
}


# () . LOGGING_ENABLED=true
function enable_logging() { 
    LOGGING_ENABLED=true;
}
# () . LOGGING_ENABLED=
function disable_logging() {
    unset LOGGING_ENABLED;
}


# () . LOGGING_IGNORED=true;
function ignore_logging() {
    LOGGING_IGNORED=true;
}

# () . LOGGING_IGNORED=;
function acknowledge_logging() {
    unset LOGGING_IGNORED;
}


# () . LOG_DATA >> LOG_FILE
function log() {
    
    if [[ -z "$LOGGING_IGNORED" ]] && [[ -n "$LOGGING_ENABLED" ]]; then                
        LOGGING::log_data "$LOG_DATA" "$LOG_FILE";
    fi    
}

# (String log_data, String log_file) . log_data >> log_file
function LOGGING::log_data() {
    
    local log_data="$1";
    local log_file="$2";
    echo -en "$log_data" >> "$log_file";
    
}