#!/bin/bash

## Implements some file handling utility functions

## The archive directory contains named sub-directories.
## These subdirectories contain numbered files, or versions of push
## Stored folders are tarred first on import, and unarchived on export
## If ID is not supplied, the highest ID is used

## repo_path => repository, contains all archives
## archive_path => archive, contains all versions
## file_path => tar'd file or directory (renamed with an id)
## repo_path/archive_name/ids...

debug_on FILES;


# (String archive_path) => int id
function FILES::get_highest_id() {
    alert FILES 'in get_highest_id';
    
    local archive_path="$1";    
    local highest=;
    
    for file in "$archive_path"/*; do
    
        local filename="$(basename $file)";
        
        if [[ "$filename" == '*' ]]; then 
            break;
        elif [[ "$filename" =~ [0-9]+ ]]; then
            
            [[ -z "$highest" ]] || (( filename > highest )) && highest=$filename;
            
            alert FILES "File $filename is a number";
        else
            alert FILES "$filename is not a number";
        fi
    
    done
    
    echo $highest;
}

# (String archive_path) => int id
function FILES::get_next_id() {
    alert FILES 'in get_next_id'
    local archive_path="$1";
    
    local highest_id=$(FILES::get_highest_id "$archive_path");
    alert $highest_id
    [[ -z "$highest_id" ]] && echo 0 || echo $(( highest_id + 1 ));
}

# (String source_path, String repo_path, String archive_name, int? id)
function import_file() {
    alert FILES 'in import_file'
    
    local source_path="$1";
    local repo_path="$2";
    local archive_name="$3";
    local id="$4";

    
    if [[ ! -e "$source_path" ]]; then 
        ERROR::path_no_exist "$source_path";
        return $ERROR_ID;
    fi
    
    local archive_path="$repo_path/$archive_name";
    
    [[ ! -e "$archive_path" ]] && mkdir -p "$archive_path";        
    
    if [[ -z "$id" ]]; then 
        id=$(FILES::get_next_id "$archive_path");
    else
        rm -v "$archive_path/$id"
    fi
    
    alert FILES "next id: $id";
    
    tar -cf "$archive_path/$id" "$source_path";
}