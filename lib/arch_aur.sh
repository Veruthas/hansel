#!/bin/bash

## SUMMARY: Implements AUR package installation
## DEPENDS: lib/nodes.sh

# break up AUR_INSTALL into install, download and build
global ARCH_AUR_URL="https://aur.archlinux.org/packages";

global ARCH_ARM_AUR_URL="http://seblu.net/a/archive/aur";


# (String date) => String arm_aur_url
function ARCH::get_arm_aur_url() {
    alert ARCH 'in ARCH::get_arm_aur_url'
    
    local date="$1";
    
    date=$(date -d "$date" +'%Y/%m/%d');
    
    echo "$ARCH_ARM_AUR_PACKAGE_URL/$date";
}


# (String aur_url, String package) => package_url
function ARCH::get_aur_package_url() {    
    alert ARCH 'in ARCH::get_aur_package_url';
    
    local aur_url="$1";
    local package="$2";
    
    echo "$aur_url/${package:0:2}/$package/$package.tar.gz";
}


# (String aur_url, String path, String package)
function ARCH::aur_download_package() {
    alert ARCH 'in ARCH::aur_download';

    # Will download node:    
    #    ##/build/$PACKAGE.tar.gz
    #    ##/build/$PACKAGE/*

    local aur_url="$1";
    
    local path="$2";
    
    local package="$3";

    local package_url="$(ARCH::get_aur_package_url $aur_url $package)";            
               
               
    local err_no;
    
    
    # set up build directory
    local build_path="$path/build";
    mkdir -pv "$build_path";
    
    local old_pwd="$PWD";    
    cd "$build_path";        
    
    # download pacakge
    wget "$package_url" ; err_no="$?";
    
    if (( err_no != 0 )); then
        throw "$err_no" "Could not find package '$package'.";
        return $?;
    fi
    
    # extract package
    tar -zxf "$package.tar.gz";
        
    
    cd "$old_pwd";
}

# (String path, String package)
function ARCH::aur_build_package() {
    alert ARCH 'in ARCH:aur_build';
    
    # Will build node and move build package to main directory
    #    ##/build/$PACKAGE.tar.gz
    #    ##/build/$PACKAGE/*        
    #    ##/*.pkg.tar.xz
    
    
    local path="$1";

    local package="$2";    
        
    
    local package_path="$path/build/$package";
    
    local old_pwd="$PWD";        
    
    cd "$package_path";
            
            
    local asroot="$( (( EUID == 0 )) && echo --asroot )";    
    
    makepkg "$asroot" "$confirm";     
    
    err_no="$?"; 
    
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

# (String build_path, String package_path)
function ARCH::aur_cache_package() {
    alert ARCH 'in ARCH::aur_cache_package';
    
    local build_path="$1";
    
    local package_path="$2";
    
    
    mkdir -pv "$package_path"        
    
    local package_node=$(NODES::create_dir "$package_path");
    
    package_node=$(NODES::get_path "$package_path" "$package_node");
    
    
    cp -rv "$build_path"/* "$package_node";
}


# (String path, bool confirm) 
function ARCH::aur_install_package() {
    alert ARCH 'in ARCH::aur_install_package';
    
    local path="$1";
    
    local confirm="$( [[ -z $2 ]] && echo --noconfirm)";
    
    local file=$(ls "$path"/*.pkg.tar.xz);
    
    
    local err_no;        
        
    
    sudo pacman -U "$file" $confirm; 
    
    err_no="$?";
    
    
    if (( err_no != 0 )); then 
        throw "$err_no" "Could not install package '$package'."; 
        return $?; 
    fi    
}



# (String aur_url, String aur_path, String package, bool confirm, bool force)
function ARCH::install_aur() {
    alert DEBUG 'In ARCH::install_aur';
    
    local aur_url="$1";
    
    local aur_path="$2";
    
    local package="$3";
    
    local confirm="$4";
    
    local force="$5";
                
    
    local package_path="$aur_path/$package";
    
    
    local err_no;   
    
        
    if [[ ! -e "$package_path" ]] || [[ -n "$force" ]]; then
        
        local tmp_path="$(mktemp -d)";
        
        # download package
        ARCH::aur_download_package "$aur_url" "$tmp_path" "$package";
        err_no="$?" && ((err_no != 0)) && return "$err_no";
        
        # build package
        ARCH::aur_build_package "$tmp_path" "$package"; 
        err_no="$?" && ((err_no != 0)) && return "$err_no";
        
        # copy files into aur node
        ARCH::aur_cache_package "$tmp_path" "$package_path";
        err_no="$?" && ((err_no != 0)) && return "$err_no";
        
    fi        
        
    # Get latest aur cached package
    local package_node=$(NODES::get_last "$package_path");
            
    local package_node=$(NODES::get_path "$package_path" "$package_node");
    
    
    # install package
    ARCH::aur_install_package "$package_node" "$confirm";
    err_no="$?" && ((err_no != 0)) && return "$err_no";
}