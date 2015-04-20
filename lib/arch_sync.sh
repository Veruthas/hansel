#!/bin/bash


# (String date, String sync_path, String mirror_file, String date_file)
function ARCH::sync() {
    alert ARCH 'in ARCH::sync';
    
    local date="$(ARCH::formate_date $1)";
    
    local sync_path="$2";
    
    local mirror_file"$3";
    
    local date_file="$4";
        
    
    sudo echo "Server=$(ARCH::get_arm_server_url $date)" > "$mirror_file";
    
    sudo echo "$date" > "$date_file";
    
    # check to see if sync already exists,
    # other download a new sync
}

# TODO: ADD UTIL BACKUP METHOD (add a .# suffix => a.txt -> a.txt.0 ...)



global ARCH_ARM_SERVER_URL="http://seblu.net/a/arm";

# (String date) => YYYY/MM/DD
function ARCH::format_date() {
    date -d $1 +'%Y/%m/%d';
}

# (String date) => arm_server_url
function ARCH::get_arm_server_url() {

    local date="$(ARCH::format_date $1)";
    
    echo "$ARCH_ARM_SERVER_URL/$date/\$repo/os/\$arch";

}

# (String package_path, bool confirm)
function ARCH::update() {
    
    alert ARCH 'in ARCH::update';
    
    local package_path="$package_path";
    
    local confirm="$( [[ $3 != true ]] && echo --noconfirm)";
    
    
    sudo mount -v --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
    
    sudo pacman -Suu $confirm;
    
    sudo umount -v "$ARCH_REAL_PACKAGE_PATH";        
}

# Contacting you to ask if there are any updates