#!/bin/bash

global ARCH_SYNC_PATH_NAME="Sync";

# virtual () => String sync_directory
function ARCH::sync_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String sync_path
function ARCH::sync_path() {
    echo "$(ARCH::sync_directory)/$ARCH_SYNC_PATH_NAME";
}


global ARCH_SERVER_DATE_FILE_NAME='date.dat';

# virtual () => String server_date_directory
function ARCH::server_date_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String server_date_file_name
function ARCH::server_date_file_name() {
    echo "$(ARCH::aur_directory)/$ARCH_AUR_PATH_NAME";
}


# virtual () => YYYY/MM/DD
function ARCH::get_server_date() {
    cat "$(ARCH::server_date_path)";
}

# (String date)
function ARCH::set_server_date() {
    local date="$1";
    
    date="$(date -d $date +'%Y/%m/%d')";
    
    echo "$date" > "$(ARCH::server_date_path)";
    
    ARCH::set_arm_mirror "$date";
}

# () -> pacman -Syy and copy
function ARCH::sync() {
:
}

function ARCH::update() {
:
}