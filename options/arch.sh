#!/bin/bash

## Implements package functionality

DEBUG::off "ARCH";

# VIRTUAL | () => package_path
function ARCH::package_path() {
    alert OPTIONS_VARS 'in ARCH::package_path';
    
    echo "$HOME/.hansel/pkgs";
}

# ([--confirm | --noconfirm], String pkg)
OPTIONS::add 'ins';
function OPTIONS::ins() {
    :    
}