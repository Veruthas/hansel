#!/bin/bash

## SUMMARY: Implements arch sync functionality

global ARCH_REAL_SYNC_PATH='/var/lib/pacman/sync';

# (String YYYY/MM/DD, String sync_path, String mirror_file, String date_file)
function ARCH::sync() {
    alert ARCH 'in ARCH::sync';
        
    local date="$1";
    if ! ARCH::verify_date_format "$date"; then
        error; return $?
    fi        
    
    local sync_path="$2";
    
    local mirror_file="$3";
    
    local date_file="$4";
        
    # replace / with . for path
    local new_sync_path="$sync_path/${date////.}";            
    
    
    # check if path exists
    local sync_mirror=$(ARCH::get_arm_server_url "$date");
    
    if ! UTIL::url_path_exists "$sync_mirror"; then
        throw 1 "Server '$sync_mirror' does not exist (date may not exist yet...).";
        return $?;
    fi
    
    sudo echo "Server=$sync_mirror/\$repo/os/\$arch" > "$mirror_file";
    
    sudo echo "$date" > "$date_file";
    
    
    # check if sync already cached    
    if [[ -e "$new_sync_path" ]]; then        
        echo "Cached sync found, copying...";
        sudo rm -rv "$ARCH_REAL_SYNC_PATH";
        sudo cp -rv "$new_sync_path" "$ARCH_REAL_SYNC_PATH";        
    else
        echo "No cached sync found, downloading...";
        sudo pacman -Sy;        
        cp -rv "$ARCH_REAL_SYNC_PATH" "$new_sync_path";
    fi            
}


global ARCH_ARM_SERVER_URL="http://seblu.net/a/arm";


# (String date) -> 0/1
function ARCH::verify_date_format() {
    local date="$1";
    
    if [[ "$date" =~ ^[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]$ ]]; then
        return 0;
    else
        throw 1 "Bad date format '$date'";
        return $?;
    fi
}

# (String date) => arm_server_url
function ARCH::get_arm_server_url() {
    alert ARCH 'in ARCH::get_arm_server_url';
    
    local date="$1";
    
    echo "$ARCH_ARM_SERVER_URL/$date";

}

# (String package_path, bool confirm)
function ARCH::update() {    
    alert ARCH 'in ARCH::update';
    
    local package_path="$package_path";
    
    local confirm="$( [[ $3 != true ]] && echo --noconfirm)";
    
    
    sudo mount -v --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
    
    sudo pacman -Suu $confirm;
    
    sudo umount -v "$ARCH_REAL_PACKAGE_PATH";        
}
