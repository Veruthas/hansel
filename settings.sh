#!/bin/bash

## Wraps up the various virtual functions (giving different paths, etc)

DEBUG::off SETTINGS;


ERROR::set_simple_header


function SETTINGS::cache_path() {
    if DEBUGGING; then
        echo "$SCRIPT_PATH/../cache";
    else
        realpath "/etc/hansel.d/cache";
    fi
}

function SETTINGS::settings_path() {
    if DEBUGGING; then
        echo "$SCRIPT_PATH/../settings";
    else
        realpath "/etc/hansel.d/settings";
    fi
}

function VARS::var_file() {
    echo "$(SETTINGS::settings_path)/vars.dat"
}

function TRACE::trace_file() {
    echo "$(SETTINGS::settings_path)/trace.dat"
}

function ARCH::date_file() {
    echo "$(SETTINGS::settings_path)/date.dat"
}


function ARCH::aur_path() {
    echo "$(SETTINGS::cache_path)/Aur"
}

function ARCH::package_path() {
    echo "$(SETTINGS::cache_path)/Packages"
}

function ARCH::package_log_file() {
    echo "$(SETTINGS::cache_path)/packages.log"
}