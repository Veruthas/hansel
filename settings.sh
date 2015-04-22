#!/bin/bash

## Wraps up the various virtual functions (giving different paths, etc)

DEBUG::off SETTINGS;

ERROR::set_simple_header


# (String path_name)
function SETTINGS::get_sub_path() {
    alert SETTINGS 'in SETTINGS::get_sub_path';
    
    local path_name="$1";
    
    local settings_path="$(SETTINGS::settings_path)";
    
    local path_file="$settings_path/$path_name.dat";
    local path;
    
    if [[ -e "$path_file" ]]; then
        path="$(cat $path_file)";
    else
        path="$settings_path/$path_name";
        mkdir -p "$path";
        chmod a+rwx "$path";
        SETTINGS::set_sub_path "$path_name" "$path";
    fi
    
    echo "$path";
}

# (String path_name, String path) 
function SETTINGS::set_sub_path() {
    alert SETTINGS 'in SETTINGS::set_sub_path';
        
    local path_name="$1";
    
    local path="$2";
    
    
    local settings_path="$(SETTINGS::settings_path)";
    
    local path_file="$settings_path/${path_name}.dat";
    
    
    # if no path name is supplied
    [[ -z "$path" ]] && path="$settings_path/$path_name";
            
    # create path if does not exist
    [[ ! -e "$path" ]] && mkdir -pv "$path";
    
    # save path location
    echo "$path" > "$path_file";
}


# () => String settings_path
function SETTINGS::settings_path() {
    if DEBUGGING; then
        echo '/tmp/hansel-settings';
    else
        echo '/etc/hansel.d';
    fi
}


# () => String var_path
function SETTINGS::var_path() {
    alert SETTINGS 'in SETTINGS::var_path';
    
    SETTINGS::get_sub_path "var_path";
}

# (String var_path) -> var_path
function SETTINGS::set_var_path() {
    alert SETTINGS 'in SETTINGS::var_path';
    
    local var_path="$1";
    
    SETTINGS::set_sub_path "var_path" "$var_path";
}



# () => String cache_path
function SETTINGS::cache_path() {
    alert SETTINGS 'in SETTINGS::cache_path';
    
    SETTINGS::get_sub_path "cache_path";
}

# (String cache_path) -> cache_path
function SETTINGS::set_cache_path() {
    alert SETTINGS 'in SETTINGS::cache_path';
    
    local cache_path="$1";
    
    SETTINGS::set_sub_path "cache_path" "$cache_path";
}


# rewrite this
[[ ! -e "$(SETTINGS::settings_path)" ]] && mkdir -pv "$(SETTINGS::settings_path)" && chmod a+rwx "$(SETTINGS::settings_path)";



## OVERWRITTEN PATHS
function TRACE::trace_file_directory() {
    SETTINGS::var_path;
}

function VAR_OPTIONS::vars_file_directory() {
    SETTINGS::var_path;
}

function ARCH_OPTIONS::date_file_directory() {
    SETTINGS::var_path;
}

function ARCH_OPTIONS::log_directory() {
    SETTINGS::var_path;
}



function ARCH_OPTIONS::sync_cache_directory() {
    SETTINGS::cache_path;
}

function ARCH_OPTIONS::aur_cache_directory() {
    SETTINGS::cache_path;
}

function ARCH_OPTIONS::package_cache_directory() {
    SETTINGS::cache_path;
}


function ARCH_OPTIONS::mirror_file_directory() {
    SETTINGS::var_path;
}

function ARCH_OPTIONS::mirror_file_path() {
    
    if DEBUGGING; then
        local path="$(ARCH_OPTIONS::mirror_file_directory)/$ARCH_OPTIONS_MIRROR_FILE_NAME";
        echo "$path"; touch "$path";
    else
        echo '/etc/pacman.d/mirrorlist';
    fi
}
