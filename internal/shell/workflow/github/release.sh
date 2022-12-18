#!/bin/bash

echo 'Workflow GitHub release'

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

TAG="$1"

. ex/util/require TAG

. ex/util/json -f assemble/vcs/commit.json \
 -sfs .sha GIT_COMMIT_SHA

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .run_number CI_BUILD_NUMBER \
 -sfs .html_url CI_BUILD_HTML_URL

BODY='{}'
. ex/util/json_merge -v BODY \
 ".name=\"$TAG\"" \
 ".tag_name=\"$TAG\"" \
 ".target_commitish=\"$GIT_COMMIT_SHA\"" \
 ".body=\"CI build [#$CI_BUILD_NUMBER]($CI_BUILD_HTML_URL)\"" \
 '.draft=false' \
 '.prerelease=true'

mkdir assemble/github \
 || . ex/util/throw 21 "Illegal state!"

ex/github/release.sh "$BODY" \
 || . ex/util/throw 22 "Illegal state!"

ASSETS="[]"
for it in \
 "CIExtension-${TAG}.zip" \
 "CIExtension-${TAG}.zip.sig"; do
 ASSET="{}"
 . ex/util/jq/merge ASSET \
  ".name=\"$it\"" \
  ".label=\"$it\"" \
  ".path=\"assemble/project/artifact/$it\""
 . ex/util/jq/merge ASSETS ".+=[$ASSET]"
done

ex/github/release/upload/assets.sh "$ASSETS" \
 || . ex/util/throw 31 "Illegal state!"
