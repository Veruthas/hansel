#!/bin/bash

## SUMMARY: Implements pacman package installation


global ARCH_REAL_PACKAGE_PATH="/var/cache/pacman/pkg";

global ARCH_MIRRORLIST_PATH="/etc/pacman.d/mirrorlist";


# (String package_path)
function ARCH::mount_package_cache() {
    alert DEBUG "In ARCH::mount_package_cache";
    
    local package_path="$1";
    
    IS_ROOT && mkdir -pv "$ARCH_REAL_PACKAGE_PATH" && mount -v --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
    IS_USER && sudo mkdir -pv "$ARCH_REAL_PACKAGE_PATH" && sudo mount -v --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
}

# ()
function ARCH::unmount_package_cache() {
    alert DEBUG "In ARCH::unmount_package_cache";
        
    IS_ROOT && umount -v "$ARCH_REAL_PACKAGE_PATH";
    IS_USER && sudo umount -v "$ARCH_REAL_PACKAGE_PATH";
}

# (String package_path, String package, bool confirm)
function ARCH::install() {    
    alert DEBUG "In ARCH::install";
    
    local package_path="$1";
    
    local package="$2";
    
    local confirm="$( [[ $3 != true ]] && echo --noconfirm)";
    
        
    ARCH::mount_package_cache "$package_path";
    
    local err_no;
    
    if IS_ROOT; then 
        pacman -S $package $confirm
        err_no="$?";
    else
        # TODO: fails if package has a space in name
        sudo pacman -S $package $confirm;
        err_no="$?";
    fi        
        
    ARCH::unmount_package_cache;
                                        
    if (( err_no != 0 )); then
        
        throw "$err_no" "'$package' not found.";        
        
        return "$?";        
    fi
}

