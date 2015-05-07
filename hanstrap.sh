#!/bin/bash

declare -r SCRIPT_FILE="$(realpath $0)";

declare -r SCRIPT_PATH="$(dirname $SCRIPT_FILE)";

declare -a SCRIPT_ARGUMENTS=("$@");


# setup pacman.conf base on bits
declare BITS=$(getconf LONG_BIT);


declare NEW_ROOT="{$1:-/mnt}";


shopt -s expand_aliases

alias hansel="$SCRIPT_PATH/hansel.sh";

# instead of sourcing (until the revamp for 2.0 using clash)
alias hansdo="hansel do";


out() { printf "$1 $2\n" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
msg() { out "==>" "$@"; }
msg2() { out "  ->" "$@";}
die() { error "$@"; exit 1; }

function HANSTRAP::confirm_ready() {
    # make sure mount is ready
    if ! mount | grep "$NEW_ROOT"; then
        die "Mount system on '/mnt' and launch hanstrap again.";        
    fi

    if ! ping -c 1 www.google.com 2>/dev/null; then
        echo "No internet connection was detected."
        read -p "Would you like to continue? " answer;
        
        [[ "$answer" != 'y' ]] && exit 1;
    fi
}

function HANSTRAP::setup_hansel_paths() {

    # This feels weird, fix?
    
    # setup var/cache path
    read -p "Enter cache path (for packages/sync): " cache_path;

    [[ -n "$cache_path" ]] && hansel path cache "$cache_path";

    # setup default cache path
    chmod a+rwx $(hansel path cache);

    # setup default var path
    chmod a+rwx $(hansel path var);
}


function HANSTRAP::setup_arm_date() {
    # setup sync => ask user for date, default to today
    read -e -p "Enter date for arm server (YYYY/MM/DD): " -i $(date +'%Y/%m/%d') datepath;

    hansel sync "$datepath";
}


function HANSTRAP::install_system() {
        
    # pacstrap
    local base_packages="base base-devel linux-headers sudo grub-bios wget"

    # copy pacman.conf file
    cp -va "$SCRIPT_PATH/files/pacman.conf.x$BITS" "/etc/pacman.conf";
        
    # mount to package cache
    hansdo ARCH::mount_package_cache "$(hansdo ARCH_OPTIONS::package_cache_path)";
    
    # install system
    ! "$SCRIPT_PATH/files/pacstrap/pacstrap" $NEW_ROOT "$base_packages" && die "Hanstrap failed using pacstrap";
    
    # unmount pkg folder
    hansdo ARCH::unmount_package_cache;
}

function HANSTRAP::apply_fixes() {
    # makepkg.fix
    "$SCRIPT_PATH/files/makepkg.fix/fix-makepkg.sh"
}

function HANSTRAP::copy_hansel() {
    
    # cp hansel into /mnt/opt/hansel (should i get rid of hanstrap files?)
    cp -rv "$SCRIPT_PATH" "/mnt/opt/hansel";

    # ln -s /opt/hansel/hansel.sh /mnt/usr/local/bin/hansel
    ln -s /mnt/opt/hansel/hansel.sh /mnt/usr/local/bin/hansel;
    chmod a+rx /mnt/usr/local/bin/hansel;

    # cp /etc/hansel.d/ into /mnt/etc/hansel.d/
    cp -rva /etc/hansel.d /mnt/etc/hansel.d
}

function HANSTRAP::setup_fstab() {

    local FS_TABLE_FILE="/mnt/etc/fstab";

    echo "Generating fstab..."
    echo "Select device identification scheme";
    read -e -p "(u)uid, (l)abel (d)evice: " -i 'd' fstab_choice;

    # make uppercase
    fstab_choice=${fstab_choice^^}

    if [[ "$fstab_choice" == "U" ]] || [[ "$fstab_choice" == "L" ]]; then
        fstab_choice="-$fstab_choice";
    else
        unset fstab_choice;
    fi
    
    # backup old fstab
    [[ ! -e "$FS_TABLE_FILE.0" ]] && cp -v "$FS_TABLE_FILE" "$FS_TABLE_FILE.0" ;
    
    genfstab -p $fstab_choice /mnt >> "$FS_TABLE_FILE";

    read -p "Press any key to edit fstab...";

    nano "$FS_TABLE_FILE";

}


HANSTRAP::confirm_ready;
HANSTRAP::setup_hansel_paths;
HANSTRAP::setup_arm_date;
HANSTRAP::install_system;
HANSTRAP::apply_fixes;
HANSTRAP::copy_hansel;
HANSTRAP::setup_fstab;