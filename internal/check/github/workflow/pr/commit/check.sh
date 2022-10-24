#!/bin/bash

SCRIPT='ex/github/workflow/pr/commit.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

echo "Not implemented!"; exit 1 # todo

echo "
Check success..."

echo "Not implemented!"; exit 1 # todo

exit 0
