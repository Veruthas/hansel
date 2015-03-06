#!/bin/bash

declare LOG_FILE="/dev/null";

declare LOG_DATA=;

declare LOGGING_ENABLED=;


# (String log_file)
function set_log_file() {    
    LOG_FILE="$1";
}

# (String log_data)
function set_log_data() {
    LOG_DATA="$1";
}

# () . LOGGING_ENABLED = true
function enable_logging() {    
    LOGGING_ENABLED=true;
}
# () . LOGGING_ENABLED = false
function disable_logging() {
    unset LOGGING_ENABLED;
}

# () . LOG_DATA >> LOG_FILE
function log() {
    
    if [[ -n "$LOGGING_ENABLED" ]]; then
        LOGGING::log_data "$LOG_DATA" "$LOG_FILE";
    fi    
}

# (String log_data, String log_file) . log_data >> log_file
function LOGGING::log_data() {
    
    local log_data="$1";
    local log_file="$2";
    echo "$log_data | $log_file";
    echo -en "$log_data" >> "$log_file";
    
}