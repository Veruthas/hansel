# hansel
Bash script for logging and retracing an arch installation.


system directory

    The directory to install to (/mnt)

package directory

    Contains all packages
    
archive directory
    <record #>
    
        files           => contains all imported files
        sync            => contains sync and gnupg if exists
        
        last            => id of last record
        next            => id(s) of next record
        
        sync_date.dat   => YYYY/MM/DD
        
        log.dat
            # Date-Time
            command


settings directory      => /etc/hansel.d

    package     -> Link to package directory
    archive     -> Link to archive directory
    record      -> Link to current record
    
    vars.dat    -> variables
    
    line.dat    -> current line of logfile
    
    [trace.dat] -> path of trace (if tracing)
    
        
hanstrap <system> <package> <archive> [<record #> | <date>]

    0) Gets paths:
        Asks for system path
        Asks for package path
        Asks for archive path
        Asks for record # or date  
            If <date> creates a new record in archive
            If <record #> uses trace back for base
    
    1) Installs base to system    
        Binds package directory to pkg directory
        
    2) Create /etc/logarch.d
        Adds all directory links
        Creates vars.dat
        Creates line.dat (0)
        Adds trace.dat if tracing
    
    3) Installs logarch to /usr/bin
    
    3) Asks about gen-fstab (u|l|d)    
    
    4) chroots (traces if trace exists)

hansel

    (* is not yet implemented)
    BASIC OPTIONS
    do  <command>
    if  <command> ...    
    
    ignore ...
    pause [prompt]    

    *trace                       
    
    VARIABLE OPTIONS
    set [--as <value> | --from command ] <variable>...
    unset <variable>...
    vars ...
    on  <variable> ...    
    
    FILE OPTIONS
    *import <source> <name> [id]
    *export <destination> <name> [id]
    *remove <name> [id]
    *files [name]
    
    PACKAGE OPTIONS
    *ins [--confirm] <pkg...>

    *aur [--confirm] <pkg>
    
    *custom <url> <name>
    
    *sync [YYYY.MM.DD]           does a pacman -Syyuu after added        
    
    *refresh                     checks if anything has been installed in current record (compares line#)
    
    
For pkgs, same deal, everything is in package cache

For 'do', etc, do on every install

For aur? A) How do we know if cached?
         B) What happens with multiple versions?