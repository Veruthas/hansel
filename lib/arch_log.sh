#!/bin/bash


global ARCH_PACKAGE_LOG_FILE_NAME="package.log";

# virtual () => String package_directory
function ARCH::package_log_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String log_file
function ARCH::package_log_file() {
    echo "$(ARCH::package_log_directory)/$ARCH_PACKAGE_LOG_FILE_NAME";
}



# (String category) -> simple_log
function ARCH::category() {
    local name="$1";
    
    simple_log "category" "$name";
}

# (String type, String value) -> simple_log
function ARCH::simple_log() {
    local type="$1";
    local value="$2";    
    local log_file="$(ARCH::package_log_file)";
    
    echo -e "$type\t$value" >> "$log_file";
}
