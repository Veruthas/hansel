#!/bin/bash

## Simple arch package installation options

DEBUG::off "ARCH_OPTIONS";

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


global ARCH_OPTIONS_LOG_NAME="arch.log"

# virtual () => String log_directory
function ARCH_OPTIONS::log_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String log_path
function ARCH_OPTIONS::log_path() {
    local path="$(ARCH_OPTIONS::log_directory)/$ARCH_OPTIONS_LOG_NAME";
    echo "$path"; touch "$path";
}

global ARCH_OPTIONS_SYNC_CACHE_NAME="sync"

# virtual () => String sync_cache_directory
function ARCH_OPTIONS::sync_cache_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String sync_cache_path
function ARCH_OPTIONS::sync_cache_path() {
    local path="$(ARCH_OPTIONS::sync_cache_directory)/$ARCH_OPTIONS_SYNC_CACHE_NAME";
    echo "$path"; mkdir -p "$path";
}


global ARCH_OPTIONS_DATE_FILE_NAME="date.dat"

# virtual () => String date_file_directory
function ARCH_OPTIONS::date_file_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String date_file_path
function ARCH_OPTIONS::date_file_path() {
    local path="$(ARCH_OPTIONS::date_file_directory)/$ARCH_OPTIONS_DATE_FILE_NAME";
    echo "$path"; touch "$path";
}


global ARCH_OPTIONS_MIRROR_FILE_NAME="mirror.dat"

# virtual () => String mirror_file_directory
function ARCH_OPTIONS::mirror_file_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String mirror_file_path
function ARCH_OPTIONS::mirror_file_path() {
    local path="$(ARCH_OPTIONS::mirror_file_directory)/$ARCH_OPTIONS_MIRROR_FILE_NAME";
    echo "$path"; touch "$path";
}


# ([--confirm], String package);
OPTIONS::add 'install' 'ARCH_OPTIONS::option_install';
function ARCH_OPTIONS::option_install() {
    alert ARCH_OPTIONS 'in ARCH_OPTIONS::option_install';
    
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
    
    ARCH::install "$package_path" "$package" "$confirm";
    err_no="$?" && ((err_no != 0)) && return "$err_no";
    
    ARCH_OPTIONS::log "install" "$package";  
}

# ()
function ARCH_OPTIONS::mount_package_cache() {
    alert ARCH_OPTIONS 'in ARCH_OPTIONS::mount_package_cache';
    
    local package_path="$(ARCH_OPTIONS::package_cache_path)";
    
    ARCH::mount_package_cache "$package_path";
}

# ()
function ARCH_OPTIONS::unmount_package_cache() {    
    alert ARCH_OPTIONS 'in ARCH_OPTIONS::unmount_package_cache';
    
    ARCH::unmount_package_cache 
}

# ([--confirm]/[--force]/[--version, int #], String package);
OPTIONS::add 'aur' 'ARCH_OPTIONS::option_aur';
function ARCH_OPTIONS::option_aur() {
    alert ARCH_OPTIONS 'in ARCH_OPTIONS::option_aur';
        
    local confirm;
    local version="$ARCH_AUR_DEFAULT_VERSION";
    
    while true; do
        if [[ "$1" == "--confirm" ]]; then
            confirm=true;
            shift;        
        elif [[ "$1" == "--force" ]]; then
            version="$ARCH_AUR_FORCE_BUILD_VERSION";
            shift;
        elif [[ "$1" == "--version" ]]; then
            
            if [[ ! "$2" =~ ^[0-9]+$ ]]; then
                throw 1 "Expecting a version number, '$2' given.";
                return "$?";
            fi
            
            version="$2";
            shift 2;
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
            version="$ARCH_AUR_FORCE_BUILD_VERSION";
            shift;
        elif [[ "$1" == "--version" ]]; then
            
            if [[ ! "$2" =~ ^[0-9]+$ ]]; then
                throw 1 "Expecting a version number, '$2' given.";
                return "$?";
            fi
            
            version="$2";
            shift 2;
        else
            break;
        fi
    done
    
    
    local aur_url="$ARCH_AUR_URL";
    
    local aur_path="$(ARCH_OPTIONS::aur_cache_path)";
    
    
    local err_no;
    
    ARCH::install_aur "$aur_url" "$aur_path" "$package" "$confirm" "$version";
    err_no="$?" && ((err_no != 0)) && return "$err_no";

    
    local package_node=$(ARCH::get_aur_package_node "$aur_path" "$package" "$version");
    
    ARCH_OPTIONS::log "aur" "$package $package_node";
}

# (String name)
OPTIONS::add 'category' 'ARCH_OPTIONS::option_category';
function ARCH_OPTIONS::option_category() {
    alert ARCH_OPTIONS 'in ARCH_OPTIONS::option_category';
        
    local name="$1";
    
    ARCH_OPTIONS::log "category" "$name";
}

# (String date)
OPTIONS::add 'sync' 'ARCH_OPTIONS::option_sync';
function ARCH_OPTIONS::option_sync() {
    local date="${1:-$(date +'%Y/%m/%d')}";
    
    local sync_path="$(ARCH_OPTIONS::sync_cache_path)";
    
    local mirror_file="$(ARCH_OPTIONS::mirror_file_path)";
    
    local date_file="$(ARCH_OPTIONS::date_file_path)";
    
    ARCH::sync "$date" "$sync_path" "$mirror_file" "$date_file";
    err_no="$?" && ((err_no != 0)) && return "$err_no";
    
    local package_path="$(ARCH_OPTIONS::package_cache_path)";
        
    ARCH::update "$package_path" true;
    
    ARCH_OPTIONS::log 'sync' "$date";
}


# (String name, String value)
function ARCH_OPTIONS::log() {
    alert ARCH_OPTIONS 'in ARCH_OPTIONS::log'
    
    local name="$1";
    
    local value="$2";
    
    local log_path="$(ARCH_OPTIONS::log_path)";
    
    ARCH::log "$log_path" "$name" "$value";
}



