#!/bin/bash

echo "GitHub workflow tag test..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

TAG="$1"

. ex/util/require TAG

ex/github/tag/test.sh "$TAG"
if test $? -ne 0; then
 ex/github/workflow/tag/test/on_failed.sh "$TAG"; exit 21; fi
