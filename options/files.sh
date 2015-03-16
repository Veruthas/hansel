#!/bin/bash

## Implements options for files (import, export, TODO: editing)

DEBUG::off OPTIONS_FILES


# virtual | () => repository_path
function FILES::repository_path() {
    echo "$HOME/.hansel_archives";
}

# (String source, String name, int? id) -> archives source to name/id
add_option 'import';
function option_import() {
    alert FILES 'in option_import';
    
    local source="$1";
    local name="$2";
    local id="$3";
    
    local repository_path="$(FILES::repository_path)";
    
    ARCHIVE::import_file "$source" "$(FILES::repository_path)" "$name" "$id";
    (( $? != 0 )) && terminate_error;
    
    
    local archive_path="$repository_path/$name/$id";
    
    [[ -z "$id" ]] && id="$(ARCHIVE::get_last_id $archive_path)"
    
    echo "imported '$source' to archive '$name', id #$id.";
}

# (String destination, String name, int? id) -> extracts name/id to destination
add_option 'export';
function option_export() {
    alert FILES 'in option_export';

    local dest="$1";
    local name="$2";
    local id="$3";
    
    local repository_path="$(FILES::repository_path)";
    
    ARCHIVE::export_file "$dest" "$repository_path" "$name" "$id";
    (( $? != 0 )) && terminate_error;
    
    local archive_path="$(ARCHIVE::get_archive_path $repository_path $name)";
    
    [[ -z "$id" ]] && id="$(ARCHIVE::get_last_id $archive_path)"
        
    echo "exported '$dest' from archive '$name', id #$id";
}

# (String name, int? id)
add_option 'remove'; 
function option_remove() {
    alert FILES 'in option_remove';
    
    local name="$1";    
    local id="$2";
    
    local repo_path="$(FILES::repository_path)";
    
    ARCHIVE::remove_file "$repo_path" "$name" "$id";    
    (( $? != 0 )) && terminate_error;
}

# (String? name) -> prints files or file versions >&1
add_option 'files';
function option_files() {
    local name="$1";
    
    local repo_path="$(FILES::repository_path)";
    
    ARCHIVE::list_files "$repo_path" "$name";
}