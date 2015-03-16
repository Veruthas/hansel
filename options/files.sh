#!/bin/bash

## Implements options for files (import, export, TODO: editing)

DEBUG::off OPTIONS_FILES


# virtual | () => repository_path
function FILES::repository_path() {
    echo "$HOME/.hansel_archives";
}