#!/bin/bash

## SUMMARY: Implements Arch Linux package installation functions
## DEPENDS: lib/nodes.sh

DEBUG::off ARCH;


global ARCH_PACKAGE_LOG_FILE_NAME="package.log";

# virtual () => String package_directory
function ARCH::package_log_directory() {
    echo "$HOME/.hansel";
}
# () => String log_file
function ARCH::package_log_path() {
    realpath "$(ARCH::package_log_directory)/$ARCH_PACKAGE_LOG_FILE_NAME";
}


global ARCH_DATE_FILE_NAME="date.dat"

# virtual () => String date_directory
function ARCH::date_directory() {
    echo "$HOME/.hansel";
}
# () => String date_path
function ARCH::date_path() {
    realpath "$(ARCH::date_directory)/$ARCH_DATE_FILE_NAME";
}

# () => YYYY/MM/DD
function ARCH::current_server_date() {
    cat "$(ARCH::date_path)";
}


global ARCH_PACKAGE_PATH_NAME="Packages";

# virtual () => String package_directory
function ARCH::package_directory() {
    echo "$HOME/.hansel";
}
# () => String package_path
function ARCH::package_path() {
    realpath "$(ARCH::package_directory)/$ARCH_PACKAGE_PATH_NAME";
}


global ARCH_AUR_PATH_NAME="Aur";

# virtual () => String aur_directory
function ARCH::aur_location() {
    echo "$HOME/.hansel";
}
# () => String aur_path
function ARCH::aur_path() {
    realpath "$(ARCH::aur_location)/$ARCH_AUR_PATH_NAME";
}


global ARCH_REAL_PACKAGE_PATH="/var/cache/pacman/pkg";


# (String package, bool confirm)
function ARCH::install() {    
    alert DEBUG "In ARCH::install";
    
    local package="$1";
    
    local confirm="$( [[ $2 != true ]] && echo --noconfirm)";
    
        
    local package_path="$(ARCH::package_path)";       
    
    
    [[ ! -d "$package_path" ]] && mkdir -pv "$package_path";
    
    ERROR::clear;
    
    sudo mount --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
    
    
    sudo pacman -S $package $confirm 2>/dev/null;
    
    local err_no="$?";
    
    
    sudo umount "$ARCH_REAL_PACKAGE_PATH";
                    
        
    if (( err_no != 0 )); then
        
        throw "$err_no" "'$package' not found.";        
        
        return "$?";
        
    else
        ARCH::simple_log "install" "$package";
    fi
}

global ARCH_AUR_PACKAGE_URL="https://aur.archlinux.org/packages";
global ARCH_ARM_AUR_PACKAGE_URL="http://seblu.net/a/archive/aur";

# virtual () => AUR_URL_BASE
function ARCH::get_aur_url_base() {
    echo ARCH_ARM_AUR_PACKAGE_URL/$(ARCH::current_server_date);
}

# (String package) => AUR_PACKAGE_URL
function ARCH::get_aur_package_url() {    
    local package="$1";
    
    echo "$(ARCH::get_aur_package_url)/${package:0:2}/$package/$package.tar.gz";
    
}


# (String package, bool confirm, bool force)
function ARCH::aur() {
    alert DEBUG "In ARCH::aur";
    
    local package="${1:-INVALID_PACKAGE}";
    
    local confirm="$( [[ -z $2 ]] && echo --noconfirm)";
    
    local force="$3";
    
    
    local aur_path="$(ARCH::aur_path)";
    
    local package_repo_path="$aur_path/$package";    
    mkdir -pv "$package_repo_path";
        
    
    local current_package_node=$(NODES::get_last "$package_repo_path");
        
    if [[ -z "$current_package_node" ]] || [[ -n "$force" ]]; then
        current_package_node=$(NODES::create_dir "$package_repo_path");
    fi
    
    local current_package_path=$(NODES::get_path "$package_repo_path" "$current_package_node");    
    
    local build_path="$current_package_path/.build";
    mkdir -pv "$build_path";
    
    
    local err_no;
    
    # if the package has not been downloaded yet
    if [[ ! -e $build_path/$package.tar.gz ]]; then
    
        cd "$build_path";
        
        local aur_url=$(ARCH::get_aur_package_url "$package");
        
        
        aur_url+="/${package:0:2}/$package/$package.tar.gz";
        
        
        wget "$aur_url"; err_no="$?"; 
        
        if (( err_no != 0 )); then 
            throw "$err_no" "Could not find package '$package'."; 
            return $?; 
        fi
        
        tar -zxf "$package.tar.gz";                
        
        cd -;
    fi
    
    local file=$(ls "$current_package_path"/*.pkg.tar.xz 2>/dev/null);
    
    # if the package has not been built yet
    if [[ -z "$file" ]]; then
        cd "$build_path/$package";
                
        makepkg --asroot "$confirm"; err_no="$?"; 
        
         if (( err_no != 0 )); then 
            throw "$err_no" "Could not build package '$package'."; 
            return $?; 
        fi
        
        file=$(ls *.pkg.tar.xz);                
    
        chmod -v 755 "$file";
    
        mv -v "$file" "$current_package_path/";
    
        file=$(ls "$current_package_path"/*.pkg.tar.xz);
        
        cd -;
    fi
        
             
    pacman -U "$file" "$confirm"; err_no="$?";
    
     if (( err_no != 0 )); then 
        throw "$err_no" "Could not install package '$package'."; 
        return $?; 
    fi    
    
    
    
    ARCH::simple_log "arch" "$package";    
}

# (String category) -> simple_log
function ARCH::category() {
    local name="$1";
    
    simple_log "category" "$name";
}

function ARCH::simple_log() {
    local type="$1";
    local package="$2";    
    local log_file="$(ARCH::package_log_file)";
    
    echo -e "$type\t$package" >> "$log_file";
}
