#!/bin/bash

echo "GitHub release upload assets..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

ASSETS="$1"

. ex/util/require ASSETS VCS_PAT

. ex/util/json -f assemble/github/release.json \
 -sfs .upload_url RELEASE_UPLOAD_URL

RELEASE_UPLOAD_URL="${RELEASE_UPLOAD_URL//\{?name,label\}/}"

SIZE=$(echo "$ASSETS" | jq -Mcer 'length') \
 || . ex/util/throw 101 'Illegal state!'
[ $SIZE -lt 1 ] && . ex/util/throw 102 'Illegal size!'
for ((ASSET_INDEX = 0; ASSET_INDEX<SIZE; ASSET_INDEX++)); do
 ASSET="$(echo "$ASSETS" | jq -Mc ".[$ASSET_INDEX]")"
 . ex/util/json -j "$ASSET" \
  -sfs .name ASSET_NAME \
  -sfs .label ASSET_LABEL \
  -sfs .path ASSET_PATH
 . ex/util/assert -s "$ASSET_PATH"
 echo "Upload asset [$((ASSET_INDEX + 1))/$SIZE] \"$ASSET_NAME\"..."
 OUTPUT="/tmp/$(date +%s%N)"
 rm "$OUTPUT"
 ex/util/url -u "${RELEASE_UPLOAD_URL}?name=${ASSET_NAME}&label=$ASSET_LABEL" \
  -o "$OUTPUT" \
  -h "Authorization: token $VCS_PAT" \
  -h 'Content-Type: text/plain' \
  -x POST \
  -b "$ASSET_PATH" \
  -e 201 \
  || . ex/util/throw 21 "GitHub release upload asset \"$ASSET_NAME\" error: $OUTPUT"
done
