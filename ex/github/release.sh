#!/bin/bash

echo "GitHub release..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

BODY="$1"

. ex/util/require BODY VCS_PAT

. ex/util/json -j "$BODY" \
 -sfs .name RELEASE_NAME

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

. ex/util/mkdirs assemble/github

ex/util/url -u "$REPOSITORY_URL/releases" \
 -o assemble/github/release.json \
 -x POST \
 -h "Authorization: token $VCS_PAT" \
 -d "$BODY" \
 -e 201 \
 || . ex/util/throw 21 "GitHub release \"$RELEASE_NAME\" error"

. ex/util/json -f assemble/github/release.json \
 -sfs .html_url RELEASE_HTML_URL

echo "The release $RELEASE_HTML_URL is ready."
