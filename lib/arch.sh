#!/bin/bash

## SUMMARY: Implements Arch Linux package installation functions
## DEPENDS: lib/nodes.sh

DEBUG::off ARCH;


global ARCH_PACKAGE_LOG_FILE_NAME="package.log";

# virtual () => String package_directory
function ARCH::package_log_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String log_file
function ARCH::package_log_file() {
    echo "$(ARCH::package_log_directory)/$ARCH_PACKAGE_LOG_FILE_NAME";
}


global ARCH_PACKAGE_PATH_NAME="Packages";

# virtual () => String package_directory
function ARCH::package_directory() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String package_path
function ARCH::package_path() {
    echo "$(ARCH::package_directory)/$ARCH_PACKAGE_PATH_NAME";
}


global ARCH_AUR_PATH_NAME="Aur";

# virtual () => String aur_directory
function ARCH::aur_location() {
    local dir="/tmp/hansel-settings";
    echo "$dir"; mkdir -p "$dir";
}
# virtual () => String aur_path
function ARCH::aur_path() {
    realpath "$(ARCH::aur_location)/$ARCH_AUR_PATH_NAME";
}


# virtual () => YYYY/MM/DD
function ARCH::current_server_date() {
    date +'%Y/%m/%d';
}


global ARCH_REAL_PACKAGE_PATH="/var/cache/pacman/pkg";


# (String package, bool confirm)
function ARCH::install() {    
    alert DEBUG "In ARCH::install";
    
    local package="$1";
    
    local confirm="$( [[ $2 != true ]] && echo --noconfirm)";
    
        
    local package_path="$(ARCH::package_path)";    
    mkdir -pv "$package_path";
    
    
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
    echo "$ARCH_ARM_AUR_PACKAGE_URL/$(ARCH::current_server_date)";
}

# (String package) => AUR_PACKAGE_URL
function ARCH::get_aur_package_url() {    
    alert ARCH "in ARCH::get_aur_package_url";
    
    local package="$1";
    
    echo "$(ARCH::get_aur_url_base)/${package:0:2}/$package/$package.tar.gz";    
}


# (String package, String build_path) => String tmp_path ;
function ARCH::build_aur_package() {
    alert ARCH "in ARCH::build_aur_package";
    
    local package="$1";

    local build_path="$2";
    
    local old_pwd="$PWD";
    
                        
    # download package    
    local build_path="$tmp_path/build"; 
    mkdir -v "$build_path";    
    cd "$build_path";
    
    local aur_url=$(ARCH::get_aur_package_url "$package");
    
    wget "$aur_url" ; err_no="$?";
    
    if (( err_no != 0 )); then
        throw "$err_no" "Could not find package '$package'.";
        return $?;
    fi
    
    tar -zxf "$package.tar.gz";
    
    
    # build package    
    cd "$package";
            
    local asroot="$( (( EUID == 0 )) && echo --asroot )";
    
    makepkg "$asroot" "$confirm"; err_no="$?"; 
    
    if (( err_no != 0 )); then 
        throw "$err_no" "Could not build package '$package'."; 
        return $?; 
    fi
    
    file=$(ls *.pkg.tar.xz);            

    chmod -v 755 "$file";
    
    
    # move file out of build directory
    mv -v $file ../..;
                   
            
    cd "$old_pwd";    
}

# (String package, bool confirm, bool force)
function ARCH::install_aur() {
    alert DEBUG "In ARCH::install_aur";
    
    local package="${1:-INVALID_PACKAGE}";
    
    local confirm="$( [[ -z $2 ]] && echo --noconfirm)";
    
    local force="$3";
    
    
    local aur_path="$(ARCH::aur_path)"; mkdir -pv "$aur_path";
    
    
    local package_path="$aur_path/$package";
    
        
    if [[ ! -e "$package_path" ]] || [[ -n "$force" ]]; then
        
        local tmp_path="$(mktemp -d)";
        ARCH::build_aur_package "$package" "$tmp_path";
                
        # copy files into aur node
        mkdir -pv "$package_path"
        
        
        local package_node=$(NODES::create_dir "$package_path");
        
        package_node=$(NODES::get_path "$package_path" "$package_node");
        
        
        cp -rv "$tmp_path"/* "$package_node";
        
    fi        
        
    # Get latest aur installation
    local package_node=$(NODES::get_last "$package_path");
            
    local package_node=$(NODES::get_path "$package_path" "$package_node");
    
    
    local err_no;        
    
    file=$(ls "$package_node"/*.pkg.tar.xz);
        
    sudo pacman -U "$file" "$confirm"; err_no="$?";
    
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
