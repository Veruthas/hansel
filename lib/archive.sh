#!/bin/bash

## Implements archive handling utility functions

## The archive directory contains named sub-directories.
## These subdirectories contain numbered files, or versions of push
## Stored folders are tarred first on import, and unarchived on export
## If ID is not supplied, the highest ID is used

## repo_path => repository, contains all archives
## archive_path => archive, contains all versions
## file_path => tar'd file or directory (renamed with an id)
## repo_path/archive_name/ids...

[[ -z "$ARCHIVE" ]] && declare ARCHIVE=true || return;

DEBUG::on ARCHIVE;