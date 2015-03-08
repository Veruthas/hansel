#!/bin/bash

add_option "do";
function option_do() {
    eval "$@";
    enable_logging;
}