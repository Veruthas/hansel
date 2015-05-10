#!/bin/bash

declare -r SCRIPT_FILE="$(realpath $0)";

declare -r SCRIPT_PATH="$(dirname $SCRIPT_FILE)";

declare -a SCRIPT_ARGUMENTS=("$@");


# setup pacman.conf base on bits
declare BITS=$(getconf LONG_BIT);


declare NEW_ROOT="${1:-/mnt}";


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
    printf "==> Checking new root....."
    if ! mount | grep "$NEW_ROOT" > /dev/null; then
        printf "[FAILED] "; die "Mount system on '/mnt' and launch hanstrap again.";        
    fi
    echo "[OK]";

    printf "==> Checking internet connection.....";
    
    if ! ping -c 1 www.google.com 2>/dev/null 1>&2 ; then
        echo "[FAILED] No internet connection was detected."
        read -p "Would you like to continue? " answer;
        
        [[ "$answer" != 'y' ]] && exit 1;
    fi
    echo "[OK]";
    echo
    msg "-----------------------------------------------------";
    echo;
}

function HANSTRAP::setup_hansel_paths() {
    msg "Selecting Hansel Paths..."
    # This feels weird, fix?
    
    # setup var/cache path
    read -p "Enter cache path (for packages/sync): " cache_path;

    [[ -n "$cache_path" ]] && hansel path cache "$cache_path";

    # setup default cache path
    chmod a+rwx $(hansel path cache);

    # setup default var path
    chmod a+rwx $(hansel path var);
    
    msg "-----------------------------------------------------";
    echo;
}


function HANSTRAP::setup_arm_date() {
    msg 'Selecting arm server...';
    
    # copy pacman.conf file    
    cp -a "$SCRIPT_PATH/files/pacman.conf/pacman.conf.x$BITS" "/etc/pacman.conf";
    
    # setup sync => ask user for date, default to today
    read -e -p "Enter date for arm server (YYYY/MM/DD): " -i $(date +'%Y/%m/%d') datepath;

    hansel sync "$datepath";
    msg "-----------------------------------------------------";
    echo;
    
}
function HANSTRAP::mount_system_paths() {
    msg 'Mount system paths...'
    mount proc "$NEW_ROOT/proc" -t proc -o nosuid,noexec,nodev;
    mount sys "$NEW_ROOT/sys" -t sysfs -o nosuid,noexec,nodev;
    mount udev "$NEW_ROOT/dev" -t devtmpfs -o mode=0755,nosuid;
    mount devpts "$NEW_ROOT/dev/pts" -t devpts -o mode=0620,gid=5,nosuid,noexec;
    mount shm "$NEW_ROOT/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev;
    mount run "$NEW_ROOT/run" -t tmpfs -o nosuid,nodev,mode=0755;
    mount tmp "$NEW_ROOT/tmp" -t tmpfs -o mode=1777,strictatime,nodev,nosuid;
    msg "-----------------------------------------------------";
    echo;
}

function HANSTRAP::unmount_system_paths() {
    
    local paths="tmp run dev/shm dev/pts dev sys proc";

    for path in $paths; do
        umount "$NEW_ROOT/$path";
    done
}

function HANSTRAP::pacstrap() {    
    local base_packages="$@";
    local error_no
      
    msg 'Creating install root at %s' "$NEW_ROOT"
    mkdir -m 0755 -p "$NEW_ROOT"/var/{cache/pacman/pkg,lib/pacman,log} "$NEW_ROOT"/{dev,run,etc}
    mkdir -m 1777 -p "$NEW_ROOT"/tmp
    mkdir -m 0555 -p "$NEW_ROOT"/{sys,proc}

    trap 'HANSTRAP::unmount_system_paths' EXIT INT ;
    HANSTRAP::mount_system_paths;

    # HACK: copy, need to do this twice?
    cp -ar "/var/lib/pacman/sync" "$NEW_ROOT/var/lib/pacman/sync";
    cp -a "/etc/pacman.conf" "$NEW_ROOT/etc/pacman.conf";    
    mkdir -p "$NEW_ROOT/etc/pacman.d";    
    cp -arv /etc/pacman.d/* "$NEW_ROOT/etc/pacman.d";
    
    # TODO: individual download each package first, maybe with a .mid extension?
    pacman -r "$NEW_ROOT" -S $base_packages;
    
    # HACK: copy, apparently one of the packages installed overwrites these (filesystem one?)
    cp -ar "/var/lib/pacman/sync" "$NEW_ROOT/var/lib/pacman/sync";
    cp -a "/etc/pacman.conf" "$NEW_ROOT/etc/pacman.conf";    
    mkdir -p "$NEW_ROOT/etc/pacman.d";    
    cp -arv /etc/pacman.d/* "$NEW_ROOT/etc/pacman.d";
       
    
    HANSTRAP::unmount_system_paths;
    trap - EXIT
    error_no="$?";
    
    return $error_no;
}


function HANSTRAP::install_system() {

    msg "Installing base system...";
    
    local base_packages="base base-devel linux-headers sudo grub-bios wget"    
        
    # mount package cache
    hansdo ARCH::mount_package_cache "$(hansdo ARCH_OPTIONS::package_cache_path)";
    
    # install system
    HANSTRAP::pacstrap "$base_packages";
    
    # umount package cache
    hansdo ARCH::unmount_package_cache;
    
    msg "-----------------------------------------------------";
    echo;    
}

function HANSTRAP::apply_fixes() {
    msg "Applying fixes...";
    
    # makepkg.fix
    "$SCRIPT_PATH/files/makepkg.fix/fix-makepkg.sh"           
    
    msg "-----------------------------------------------------";
    echo;
}

function HANSTRAP::copy_hansel() {
    
    msg "Installing Hansel..."
    # cp hansel into /mnt/opt/hansel (should i get rid of hanstrap files?)
    cp -rv "$SCRIPT_PATH" "/mnt/opt/hansel";

    # ln -s /opt/hansel/hansel.sh /mnt/usr/local/bin/hansel
    ln -s /opt/hansel/hansel.sh /mnt/usr/bin/hansel;
    #chmod a+rx /mnt/usr/local/bin/hansel;

    # cp /etc/hansel.d/ into /mnt/etc/hansel.d/
    cp -rva /etc/hansel.d /mnt/etc/hansel.d
    msg "-----------------------------------------------------";
    echo;
}

function HANSTRAP::setup_fstab() {

    local FS_TABLE_FILE="/mnt/etc/fstab";

    msg "Generating fstab..."
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

pause() { read -p "Press any key to continue..."; };


HANSTRAP::confirm_ready;

HANSTRAP::setup_hansel_paths;

HANSTRAP::setup_arm_date;

HANSTRAP::install_system;

HANSTRAP::setup_fstab;

HANSTRAP::apply_fixes;

HANSTRAP::copy_hansel;


if [[ -e "$SCRIPT_PATH/../trace-scripts" ]]; then
    mkdir -pv "$NEW_ROOT/root/Installation";
    mount --bind "$SCRIPT_PATH/../trace-scripts" "$NEW_ROOT/root/Installation";
fi

arch-chroot "$NEW_ROOT"

umount "$NEW_ROOT/root/Installation";