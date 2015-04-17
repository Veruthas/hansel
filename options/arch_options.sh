#!/bin/bash

## Simple arch package installation options

DEBUG::on "ARCH_OPTIONS";


# ([--confirm], String package);
OPTIONS::add 'install' 'ARCH::option_install';
function ARCH::option_install() {
    alert ARCH_OPTIONS "in ARCH::option_install";
    
    local confirm=;
    
    if [[ "$1" == --confirm ]]; then
        confirm="true";
        shift;
    fi
    
    local package="$1";    
       
    
    ARCH::install "$package" "$confirm"
}

# ([--confirm]/[--force], String package);
OPTIONS::add 'aur' 'ARCH::option_aur';
function ARCH::option_aur() {
    alert ARCH_OPTIONS "in ARCH::option_aur";
        
    local confirm;
    local force;
    
    while true; do
        if [[ "$1" == "--confirm" ]]; then
            confirm=true;
            shift;        
        elif [[ "$1" == "--force" ]]; then
            force=true;
            shift;
        else
            break;
        fi
    done
    
    local package="$1";
    
    ARCH::install_aur "$package" "$confirm" "$force";
}

# (String name)
OPTIONS::add 'category' 'ARCH::option_category';
function ARCH::option_category() {
    alert ARCH_OPTIONS "in ARCH::option_category";
    
    local name="$1";
    
    ARCH::category "$name"
}

