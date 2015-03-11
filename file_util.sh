#!/bin/bash

## Implements some file handling utility functions

## The archive directory contains named sub-directories.
## These subdirectories contain numbered files, or versions of push
## Stored folders are tarred first on import, and unarchived on export
## If ID is not supplied, the highest ID is used
## TODO: store diff instead

## repo_path => repository, contains all archives
## archive_path => archive, contains all versions
## file_path => tar'd file or directory (renamed with an id)


## archive path => contains all archives
debug_off FILES;


