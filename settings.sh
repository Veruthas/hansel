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