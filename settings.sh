#!/bin/bash

## Wraps up the various virtual functions (giving different paths, etc)

DEBUG::off SETTINGS;


ERROR::set_simple_header


function SETTINGS::settings_path() {
    if DEBUGGING; then
        echo "$SCRIPT_PATH/../settings";
    else
        echo "/etc/hansel.d/settings";
    fi
}

function VARS::var_file() {
    echo "$(SETTINGS::settings_path)/vars.log"
}

function ARCH::aur_path() {
    echo "$(SETTINGS::settings_path)/Aur"
}

function ARCH::package_path() {
    echo "$(SETTINGS::settings_path)/Packages"
}

function ARCH::package_log_file() {
    echo "$(SETTINGS::settings_path)/packages.log"
}

function TRACE::trace_file() {
    echo "$(SETTINGS::settings_path)/trace_file"
}