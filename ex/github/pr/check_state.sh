#!/bin/bash

echo "GitHub pull request check state..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

ex/util/url -u "$REPOSITORY_URL/pulls/$PR_NUMBER" \
 -o "assemble/vcs/pr${PR_NUMBER}.json" \
 || . ex/util/throw 21 "Get pull request #$PR_NUMBER error!"

. ex/util/json -f "assemble/vcs/pr${PR_NUMBER}.json" \
 -sfs .state ACTUAL_STATE

. ex/util/assert -eq EXPECTED_STATE ACTUAL_STATE
