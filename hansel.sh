#!/bin/bash

declare -r HANSEL_PATH="$(realpath $(dirname $0))"


source "$HANSEL_PATH/options.sh"

process "$@";