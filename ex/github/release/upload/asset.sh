#!/bin/bash

echo "GitHub release upload asset..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

ASSET="$1"

. ex/util/require ASSET VCS_PAT

. ex/util/json -f assemble/github/release.json \
 -sfs .upload_url RELEASE_UPLOAD_URL

RELEASE_UPLOAD_URL="${RELEASE_UPLOAD_URL//\{?name,label\}/}"

. ex/util/json -j "$ASSET" \
 -sfs .name ASSET_NAME \
 -sfs .label ASSET_LABEL \
 -sfs .path ASSET_PATH

echo "Upload asset \"$ASSET_NAME\"..."

OUTPUT="/tmp/$(date +%s)"
ex/util/url -u "${RELEASE_UPLOAD_URL}?name=${ASSET_NAME}&label=$ASSET_LABEL" \
 -o "$OUTPUT" \
 -h "Authorization: token $VCS_PAT" \
 -h 'Content-Type: text/plain' \
 -x POST \
 -b "$ASSET_PATH" \
 -e 201 \
 || . ex/util/throw 21 "GitHub release upload asset \"$ASSET_NAME\" error: $OUTPUT"
