#!/bin/bash

## Simple arch package installation options

DEBUG::on "ARCH_OPTIONS";


# (String package, [--confirm]);
OPTIONS::add 'install' 'ARCH::option_install';
function ARCH::option_install() {
    alert ARCH_OPTIONS "in ARCH::option_install";
    
    local package="$1";
    
    local confirm="$2";
    
    if [[ -n "$confirm" ]] && [[ "$confirm" != "--confirm" ]]; then
        error 1 "Invalid option '$@'";
    fi
    
    ARCH::install "$package" "$confirm"
}

# (String package, [--confirm]);
OPTIONS::add 'aur' 'ARCH::option_aur';
function ARCH::option_aur() {
    alert ARCH_OPTIONS "in ARCH::option_aur";
    
    local package="$1";
    
    local confirm="$2";
    
    if [[ -n "$confirm" ]] && [[ "$confirm" != "--confirm" ]]; then
        error 1 "Invalid option '$@'";
    fi
    
    ARCH::aur "$package" "$confirm"
}

# (String name)
OPTIONS::add 'category' 'ARCH::option_category';
function ARCH::option_category() {
    alert ARCH_OPTIONS "in ARCH::option_category";
    
    local name="$1";
    
    ARCH::category "$name"
}

