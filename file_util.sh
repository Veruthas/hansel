#!/bin/bash

## Implements some file handling utility functions

debug_off FILES;

# virtual | () => String file_path
function FILES::file_path() {
    alert FILES "in FILES::file_path";
    echo ./
}