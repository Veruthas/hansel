#!/bin/bash

## Simple arch package installation options

DEBUG::on "ARCH";


# (String package, [--confirm]);
OPTIONS::add 'install' 'ARCH::option_install';
function ARCH::option_install() {

    local package="$1";
    
    local confirm="$2";
    
    if [[ -n "$confirm" ]] && [[ "$confirm" != "--confirm" ]]; then
        error 1 "Invalid option '$@'";
    fi
    
    ARCH::install "$package" "$confirm"
}

# (String package, [--confirm]);
OPTIONS::add 'aur' 'ARCH::option_aur';
function ARCH::option_aur() 
{
    local package="$1";
    
    local confirm="$2";
    
    if [[ -n "$confirm" ]] && [[ "$confirm" != "--confirm" ]]; then
        error 1 "Invalid option '$@'";
    fi
    
    ARCH::aur "$package" "$confirm"
}

# (String name)
OPTIONS::add 'category' 'ARCH::option_category';
function ARCH::option_category() {
    local name="$1";
    
    simple_log "category" "$name";
}


# virtual () => String log_file
function ARCH::package_log_file() {
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
    
    local confirm="$([[ -z $2 ]] && echo --noconfirm)";   
    
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

# (String package, bool confirm)
function ARCH::aur() {
    alert DEBUG "In ARCH::aur";
    
    local package="${1:-INVALID_PACKAGE}";
    
    local confirm="$([[ -z $2 ]] && echo --noconfirm)";
    
    
    local aur_path="$(realpath $(ARCH::aur_path))";
    
    local package_path="$aur_path/$package";
    
    local build_path="$package_path/.build";
    
    
    local current_path=$(pwd);
    
    
    local err_no;
    
    
    if [[ ! -e "$build_path" ]]; then
        mkdir -pv "$build_path";
    fi
    
    # if the package has not been downloaded yet
    if [[ ! -e $build_path/$package.tar.gz ]]; then
    
        cd "$build_path";
        
        
        aur_url="$ARCH_ARM_AUR_PACKAGE_URL/$(cat /etc/pacman.d/server_date)";
        
        aur_url+="/${package:0:2}/$package/$package.tar.gz";
        
        
        wget "$aur_url"; err_no="$?"; 
        
        if (( err_no != 0 )); then 
            throw "$err_no" "Could not find package '$package'."; 
            return $?; 
        fi
        
        tar -zxf "$package.tar.gz";                
        
        cd -;
    fi
    
    local file=$(ls "$package_path"/*.pkg.tar.xz 2>/dev/null);
    
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
    
        mv -v "$file" "../../";
    
        file=$(ls "$package_path"/*.pkg.tar.xz);
        
        cd -;
    fi
        
             
    pacman -U "$file" "$confirm"; err_no="$?";
    
     if (( err_no != 0 )); then 
        throw "$err_no" "Could not install package '$package'."; 
        return $?; 
    fi
    
    cd "$current_path";
    
    
    
    ARCH::simple_log "arch" "$package";    
}

function ARCH::simple_log() {
    local type="$1";
    local package="$2";    
    local log_file="$(ARCH::package_log_file)";
    
    echo -e "$type\t$package" >> "$log_file";
}
