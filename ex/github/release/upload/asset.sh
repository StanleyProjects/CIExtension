#!/bin/bash

echo "GitHub release upload asset..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

ASSETS="$1"

. ex/util/require ASSETS VCS_PAT

# todo util url data binary
