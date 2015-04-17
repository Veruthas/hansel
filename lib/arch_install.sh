#!/bin/bash

global ARCH_PACKAGE_PATH_NAME="Packages";

# virtual () => String package_directory
function ARCH::package_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String package_path
function ARCH::package_path() {
    echo "$(ARCH::package_directory)/$ARCH_PACKAGE_PATH_NAME";
}


global ARCH_REAL_PACKAGE_PATH="/var/cache/pacman/pkg";


# (String package, bool confirm)
function ARCH::install() {    
    alert DEBUG "In ARCH::install";
    
    local package="$1";
    
    local confirm="$( [[ $2 != true ]] && echo --noconfirm)";
    
        
    local package_path="$(ARCH::package_path)";    
    mkdir -pv "$package_path";
    
    
    ERROR::clear;
    
    sudo mount --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
    
    
    sudo pacman -S $package $confirm 2>/dev/null;
    
    local err_no="$?";
    
    
    sudo umount "$ARCH_REAL_PACKAGE_PATH";
                    
        
    if (( err_no != 0 )); then
        
        throw "$err_no" "'$package' not found.";        
        
        return "$?";
        
    else
        ARCH::simple_log "install" "$package";
    fi
}