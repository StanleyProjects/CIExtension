#!/bin/bash

echo "GitHub pull request comment..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

COMMENT="$1"
COMMENT=${COMMENT//$'\n'/"\n"}
COMMENT=${COMMENT//"\""/"\\\""}

. ex/util/require VCS_PAT PR_NUMBER COMMENT

BODY="{}"
. ex/util/json_merge -v BODY ".body=\"$COMMENT\""

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

ex/util/url -u "$REPOSITORY_URL/issues/$PR_NUMBER/comments" \
 -x POST \
 -o /tmp/output \
 -h "Authorization: token $VCS_PAT" \
 -d "$BODY" \
 -e 201 \
 || . ex/util/throw 21 "Post comment to pull request #$PR_NUMBER error!"
