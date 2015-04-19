#!/bin/bash

## Simple arch package installation options

DEBUG::on "ARCH_OPTIONS";

global ARCH_OPTIONS_PACKAGE_CACHE_NAME="Packages"

# virtual () => String package_cache_directory
function ARCH_OPTIONS::package_cache_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String package_cache_path
function ARCH_OPTIONS::package_cache_path() {
    local path="$(ARCH_OPTIONS::package_cache_directory)/$ARCH_OPTIONS_PACKAGE_CACHE_NAME";
    echo "$path"; mkdir -p "$path";    
}



global ARCH_OPTIONS_AUR_CACHE_NAME="Aur"

# virtual () => String aur_cache_directory
function ARCH_OPTIONS::aur_cache_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String aur_cache_path
function ARCH_OPTIONS::aur_cache_path() {
    local path="$(ARCH_OPTIONS::aur_cache_directory)/$ARCH_OPTIONS_AUR_CACHE_NAME";
    echo "$path"; mkdir -p "$path";
}


global ARCH_OPTIONS_LOG_NAME="simple.log"

# virtual () => String simple_log_directory
function ARCH_OPTIONS::simple_log_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String simple_log_path
function ARCH_OPTIONS::simple_log_path() {
    local path="$(ARCH_OPTIONS::simple_log_directory)/$ARCH_OPTIONS_SIMPLE_LOG_NAME";
    echo "$path"; mkdir -p "$path";
}



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
    shift;
    
    local package_path="$(ARCH_OPTIONS::package_cache_path)";
    
    # TODO: think of a better way to do options
    if [[ "$1" == --confirm ]]; then
        confirm="true";
        shift;
    fi
    
    OPTIONS::verify_no_args "$@";
    
    ARCH::install "$package_path" "$package" "$confirm"
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
    shift;
        
    
    # TODO: think of a better way to do options
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
    
    
    local aur_url="$ARCH_AUR_URL";
    
    local aur_path="$(ARCH_OPTIONS::aur_cache_path)";
    
    
    ARCH::install_aur "$aur_url" "$aur_path" "$package" "$confirm" "$force";
}

# (String name)
OPTIONS::add 'category' 'ARCH::option_category';
function ARCH::option_category() {
    alert ARCH_OPTIONS "in ARCH::option_category";
        
    local name="$1";
    
    local simple_log_path="$(ARCH::simple_log_path)";
    
    ARCH::log_category "$simple_log_path" "$name";
}

