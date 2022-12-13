#!/bin/bash

echo "GitHub pull request close..."

. ex/util/require VCS_PAT PR_NUMBER

BODY="{}"
. ex/util/json_merge -v BODY '.state="close"'

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

ex/util/url -u "$REPOSITORY_URL/pulls/$PR_NUMBER" \
 -x PATCH \
 -o "/tmp/$(date +%s)" \
 -h "Authorization: token $VCS_PAT" \
 -d "$BODY" \
 || . ex/util/throw 21 "Close pull request #$PR_NUMBER error!"
