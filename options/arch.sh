#!/bin/bash

## Simple arch package installation options

DEBUG::on "ARCH";


# virtual () => String log_file
function ARCH::log_file() {
    echo "$HOME/.hansel/log_file"
}

# virtual () => String package_path
function ARCH::package_path() {
    echo "$HOME/.hansel/Packages"
}

# virtual () => String aur_path
function ARCH::aur_path() {
    echo "$HOME/.hansel/Aur"
}

global ARCH_REAL_PACKAGE_PATH="/var/cache/pacman/pkg";

# (String package, bool confirm)
function ARCH::install() {    
    alert DEBUG "In ARCH::install";
    
    local package="$1";
    
    local confirm="$2";    
    
    local package_path="$(ARCH::package_path)";       
    
    
    [[ ! -d "$package_path" ]] && mkdir -pv "$package_path";
    
    ERROR::clear;
    
    sudo mount --bind "$package_path" "$ARCH_REAL_PACKAGE_PATH";
    
    
    sudo pacman -S $package $([[ -z $confirm ]] && echo --noconfirm ) 2>/dev/null;
    
    
    sudo umount "$ARCH_REAL_PACKAGE_PATH";
        
        
    local err_no="$?";
        
    if (( err_no != 0 )); then
        
        error "$err_no" "'$package' not found.";
        
        return "$err_no";
    else
        ARCH::simple_log "install" "$package";
    fi
}


global ARCH_AUR_PACKAGE_URL="https://aur.archlinux.org/packages";
global ARCH_ARM_AUR_PACKAGE_URL="http://seblu.net/a/archive/aur";

# (String package, bool confirm)
function ARCH::aur() {
    alert DEBUG "In ARCH::aur";
    
    local package="$1";
    
    local confirm="$2";    
    
    local aur_path="$(ARCH::aur_path)";
    
    local build_path="$aur_path/$package";
    
    local current_path=$(pwd);
    
    
    if [[ ! -e "$build_path" ]]; then
        mkdir -pv "$build_path/.build";
        
        cd "$build_path/.build";
        
        
        aur_url="$ARCH_ARM_AUR_PACKAGE_URL/$(cat /etc/pacman.d/server_date)";
        
        aur_url+="/${package:0:2}/$package/$package.tar.gz";
        
        # TODO: error point
        wget "$aur_url";
        
        tar -zxf "$package.tar.gz";
        
        
        cd "$package";
        
        # TODO: error point
        makepkg --asroot $([[ -z $confirm ]] && echo --noconfirm );
        
        chmod -v 755 *.pkg.tar.xz;
        
        mv -v *.pkg.tar.xz "../";
                
    fi
    
    cd "$build_path/";
    
    # TODO: error point
    pacman -U *.pkg.tar.xz $([[ -z $confirm ]] && echo --noconfirm );
        
    cd "$current_path";
    
    
    
    ARCH::simple_log "arch" "$package";    
}

function ARCH::simple_log() {
    local type="$1";
    local package="$2";    
    local log_file="$(ARCH::log_file)";
    
    echo -e "$type\t$package" >> "$log_file";
}