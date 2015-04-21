#!/bin/bash

## SUMMARY: Implements pacman package installation


global ARCH_REAL_PACKAGE_PATH="/var/cache/pacman/pkg";

global ARCH_MIRRORLIST_PATH="/etc/pacman.d/mirrorlist";


# (String package_path, String package, bool confirm)
function ARCH::install() {    
    alert DEBUG "In ARCH::install";
    
    local package_path="$1";
    
    local package="$2";
    
    local confirm="$( [[ $3 != true ]] && echo --noconfirm)";
    
    
    ERROR::clear;
    
    
    sudo mount -v --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
        
    sudo pacman -S $package $confirm;
    
    local err_no="$?";
        
    sudo umount -v "$ARCH_REAL_PACKAGE_PATH";
                    
                    
    if (( err_no != 0 )); then
        
        throw "$err_no" "'$package' not found.";        
        
        return "$?";
        
    fi
}