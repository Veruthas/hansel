#!/bin/bash

## Implements archive handling utility functions

## The archive directory contains named sub-directories.
## These subdirectories contain numbered files, or versions of push
## Stored folders are tarred first on import, and unarchived on export
## If ID is not supplied, the highest ID is used

## repo_path => repository, contains all archives
## archive_path => archive, contains all versions
## file_path => tar'd file or directory (renamed with an id)
## repo_path/archive_name/ids...

DEBUG::on ARCHIVE;


# (String source_path, String repo_path, String archive_name, int? id)
ARCHIVE::import_file() {
    alert ARCHIVE 'in ARCHIVE::import_file';    
    
    local source_path="$1";
    local repo_path="$2";
    local archive_name="$3";
    local id="$4";
    
    local archive_path="$repo_path/$archive_name";
    
    
    # Verify source_path
    if [[ ! -e "$source_path" ]]; then
        return $(ERROR::file_no_exist "$source_path");        
    fi
    
    ARCHIVE:::verify_path "$repo_path" || return $?;

    ARCHIVE:::verify_path "$archive_path" || return $?;
    
    # Get id
    [[ -z "$id" ]] && id=$(ARCHIVE:::get_next_id "$archive_path");
        
    # Create archive
    ARCHIVE:::import_file "$source_path" "$archive_path" "$id";
}


# (String path) -> 0|error
ARCHIVE:::verify_path() {
    if [[ -e "$path" ]]; then
        # TODO: Check permissions
        
        # Make sure path is a directory
        if [[ ! -d "$path" ]]; then
            return $(error 10 "$path is not a directory.");
        fi        
    else
        mkdir -p "$path";
    fi
}