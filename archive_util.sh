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

DEBUG::off ARCHIVE;

# TODO: much better errors+checking (does dir exist, etc)

# (String archive_path) => int id
function ARCHIVE::get_last_id() {
    alert ARCHIVE 'in ARCHIVE::get_last_id';
    
    local archive_path="$1";    
    local highest=;
    
    for file in "$archive_path"/*; do
    
        local filename="$(basename $file)";
        
        if [[ "$filename" == '*' ]]; then 
            break;
        elif [[ "$filename" =~ [0-9]+ ]]; then
            
            [[ -z "$highest" ]] || (( filename > highest )) && highest=$filename;
            
            alert ARCHIVE "File $filename is a number";
        else
            alert ARCHIVE "$filename is not a number";
        fi
    
    done
    
    echo $highest;
}

# (String archive_path) => int id
function ARCHIVE::get_next_id() {
    alert ARCHIVE 'in ARCHIVE::get_next_id'
    local archive_path="$1";
    
    local highest_id=$(ARCHIVE::get_last_id "$archive_path");
    
    [[ -z "$highest_id" ]] && echo 0 || echo $(( highest_id + 1 ));
}


# (String repo_path, String name)
function ARCHIVE::get_archive_path() {
    local repo_path="$1";
    local name="$2";
    
    echo "$repo_path/$name";
}

# (String repo_path, String name, int? id)
function ARCHIVE::get_archive_file() {
    local repo_path="$1";
    local name="$2";
    
    local id="$3";
    
    local archive_path="$(ARCHIVE::get_archive_path $repo_path $name)";
    
    [[ -z "$id" ]] && id="$(get_last_id $archive_path)";
    
    echo "$archive_path/$id";
}


# (String source_path, String repo_path, String archive_name, int? id)
function ARCHIVE::import_file() {
    alert ARCHIVE 'in ARCHIVE::import_file'
    
    local source_path="$1";
    local repo_path="$2";
    local archive_name="$3";
    local id="$4";

    
    if [[ ! -e "$source_path" ]]; then 
        ERROR::path_no_exist "$source_path";
        return $ERROR_ID;
    fi
    
    
    local archive_path="$repo_path/$archive_name";
    
    
    # Make the archive path if it doesn't exist
    [[ ! -e "$archive_path" ]] && mkdir -p "$archive_path";        
    
    
    # If no Id given, get next available one
    [[ -z "$id" ]] && id=$(ARCHIVE::get_next_id "$archive_path");
    
    
    local file_path="$archive_path/$id";        

    # remove archive if file exists
    [[ -e "$file_path" ]] && rm "$file_path";
    
    
    ARCHIVE::store "$source_path" "$file_path"
}

# (String dest_path, String repo_path, String archive_name, int? id)
function ARCHIVE::export_file() {
    alert ARCHIVE 'in ARCHIVE::export_file';

    local dest_path="$1";
    local repo_path="$2";
    local archive_name="$3";
    local id="$4";
    
    local archive_path="$repo_path/$archive_name";
    
    if [[ ! -e "$archive_path" ]]; then
        error 2 "There is no archive with name $archive_name in $repo_path";
        return 2;
    fi
    
    # If no Id given, get highest_one
    if [[ -z "$id" ]]; then 
        id=$(ARCHIVE::get_last_id "$archive_path");
        
        if [[ -z "$id" ]]; then
            error 3 "There are no versions of archive $archive_name stored.";
            return 3;
        fi    
    fi
    
    local file_path="$archive_path/$id";
    
    if [[ ! -e "$file_path" ]]; then
        error 4 "There is no version of archive $archive_name with id $id.";
        return 4;
    fi
    
    ARCHIVE::extract "$file_path" "$dest_path";
    
}

# (String repo_path, String archive_name, int? id)
function ARCHIVE::remove_file() {
    alert ARCHIVE 'in ARCHIVE::remove_file';
    
    local repo_path="$1";
    local archive_name="$2";
    local id="$3";
    
    local archive_path="$(ARCHIVE::get_archive_path $repo_path $archive_name)";
    [[ -z "$id" ]] && id="$(ARCHIVE::get_last_id $archive_path)"
    
    
    # remove file
    local file_name="$archive_path/$id";
    rm -r "$file_name"
    alert ARCHIVE "'$repo_path', '$archive_name', '$archive_path', '$id'";
    
    # rm archive if no files left
    [[ -z $(ls "$archive_path") ]] && rm -r "$archive_path";
}

# (String repo_path, String? archive_name)
function ARCHIVE::list_files() {
    alert ARCHIVE 'in ARCHIVE::list_files'
    
    local repo_path="$1";
    
    local archive_name="$2";
    
    if [[ -z "$archive_name" ]]; then
        if [[ -z $(ls "$repo_path") ]]; then
            echo "<no archives>";
        else
            echo "<archives>"
            for archive in "$(ls "$repo_path")"; do
                echo "  $archive";
            done
        fi
    else
        local archive_path="$repo_path/$archive_name";
        
        echo "<$archive_name>";
        for file in "$(ls $archive_path)"; do
            echo "  $file";
        done
    fi
}


# TODO: Should I create the dirname of destination?
# (String source, String destination) 
function ARCHIVE::store() {
    alert ARCHIVE 'in ARCHIVE::store';
    
    local source="$1";    
    local destination="$2";
    
    
    alert ARCHIVE "source='$source'; dest='$destination'";
    
    # HACK: make the tar in a temp dir, supplying a path tars the path as well
    local temp="$(mktemp -d)";    
    
    cp -vr "$source" "$temp";
                
    cd "$temp";
    
    local file="$(ls $temp)";
    
    tar czf "$file.tar.gz" "$file"
        
    cd -;            
    
    
    cp -v "$temp/$file.tar.gz" "$destination"
}

# (String source, String destination)
function ARCHIVE::extract() {
    alert ARCHIVE 'in ARCHIVE::extract'
    
    local source="$1";
    local destination="$2";
    
    
    local temp="$(mktemp -d)";
    
    tar xf "$source" -C "$temp"
    
    
    # HACK: Don't like using ls for this, but globbing isn't working
    local file="$(ls $temp)";
    
    alert ARCHIVE "$file";
    
    cp -vr "$temp/$file" "$destination";
    
    
    rm -r "$temp";
}

