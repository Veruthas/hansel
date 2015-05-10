#!/bin/bash
#We can edit /usr/bin/makepkg of course

#Add asroot to OPT_LONG (line 3366). Just search for "OPT_LONG".

#OPT_LONG=('allsource' 'check' 'clean' 'cleanbuild' 'config:' 'force' 'geninteg'
          #'help' 'holdver' 'ignorearch' 'install' 'key:' 'log' 'noarchive' 'nobuild'
          #'nocolor' 'nocheck' 'nodeps' 'noextract' 'noprepare' 'nosign' 'pkg:' 'repackage'
          #'rmdeps' 'sign' 'skipchecksums' 'skipinteg' 'skippgpcheck' 'source' 'syncdeps'
          #'verifysource' 'version' 'asroot')
#Remove EUID check (line 3577). Just search for "EUID".

#if (( ! INFAKEROOT )); then
    #if (( EUID == 0 )); then
        #error "$(gettext "Running %s as root is not allowed as it can cause permanent,\n\
#catastrophic damage to your system.")" "makepkg"
        #exit 1 # $E_USER_ABORT
        #plain "$(gettext "Running as root restored by Orc ;)")"
    #fi

declare -r SCRIPT_FILE="$(realpath $0)";
declare -r SCRIPT_PATH="$(dirname $SCRIPT_FILE)"

echo "Fixing makepkg (adding --asroot option)";
cp -v  "$SCRIPT_PATH/makepkg" "/mnt/usr/bin/makepkg";