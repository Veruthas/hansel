#!/bin/bash

## Implements sync options and methods

## Syncs contain sync date, data and log information
## as well as parent sync nodes and child syncs
DEBUG::off SYNC

# virtual () => String sync_path
function SYNC::sync_path() {
    alert SYNC 'in SYNC::sync_path';
    echo "$HOME/.hansel/sync";
}


# virtual () => int id
function SYNC::get_current_sync() {
    echo;
}
# virtual (int id) -> 
function SYNC::set_current_sync() {
    :
}

# ([int DD [, int MM, [int year]]]) -> YYYY.MM.DD
function SYNC::get_date() {
    echo 2015.01.01;
}


# ([--now | --to day [month [year]] ])
OPTIONS::add 'sync' 'SYNC::option_sync'
function SYNC::option_sync() {    
    local date=;
    
    [[ "$1" == '--now' ]] && date=$(SYNC::get_date);       
    [[ "$1" == '--to' ]]  && date=$(SYNC::get_date "$2" "$3" "$4");
    
    # TODO: catch error
    
    local sync_path=$(SYNC::sync_path);
    
    [[ ! -e "$sync_path" ]] && mkdir -p "$sync_path";
    
    
    local new_sync=$(NODES::create "$sync_path" "$(SYNC::get_current_sync)");
    
    SYNC::set_current_sync="$1";
}
