#!/bin/bash

## SUMMARY: Implements Arch Linux package installation functions
## DEPENDS: lib/nodes.sh

DEBUG::off ARCH;

source arch_log.sh
source arch_install.sh;
source arch_aur.sh;
source arch_sync.sh