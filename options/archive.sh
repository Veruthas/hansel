#!/bin/bash

## Implements options for archiving (import, export)

DEBUG::off OPTIONS_ARCHIVE


# virtual | () => repository_path
function ARCHIVE::repository_path() {
    echo "$HOME/.hansel_archives";
}