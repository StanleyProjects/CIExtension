#!/bin/bash

SCRIPT='ex/github/release/upload/assets.sh'
. ex/util/assert -s "$SCRIPT"

echo '
Check error...'

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

[ -z "$VCS_PAT" ] || . ex/util/throw 101 'Illegal state!'
$SCRIPT 1; . ex/util/assert -eqv $? 102

export VCS_PAT="$CHECK_VCS_PAT"
. ex/util/require VCS_PAT
[ -f assemble/github/release.json ] && . ex/util/throw 101 'Illegal state!'
$SCRIPT 1; . ex/util/assert -eqv $? 122

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
RELEASE_ID=80729759
. ex/util/mkdirs assemble/github/release
echo '{}' > assemble/github/release.json
RELEASE_UPLOAD_URL="https://uploads.github.com/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases/$RELEASE_ID/assets{?name,label}"
. ex/util/json_merge -f assemble/github/release.json \
 ".upload_url=\"$RELEASE_UPLOAD_URL\""
ASSETS='foo'
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 101

ASSETS='[]'
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 102

ASSET='{}'
ASSETS='[]'
. ex/util/json_merge -v ASSETS ".+=[$ASSET]"
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 41

ISSUE_NAME="asset$(date +%s%N).txt"
ISSUE="/tmp/$ISSUE_NAME"
. ex/util/json_merge -v ASSET ".name=\"$ISSUE_NAME\""
ASSETS='[]'
. ex/util/json_merge -v ASSETS ".+=[$ASSET]"
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 41

. ex/util/json_merge -v ASSET ".label=\"$ISSUE_NAME\""
ASSETS='[]'
. ex/util/json_merge -v ASSETS ".+=[$ASSET]"
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 41

. ex/util/json_merge -v ASSET ".path=\"$ISSUE\""
ASSETS='[]'
. ex/util/json_merge -v ASSETS ".+=[$ASSET]"
[ -f "$ISSUE" ] && . ex/util/throw 101 'Illegal state!'
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 121

echo '
Check success...'

ARTIFACT="assemble/github/release/assets.before.json"
ex/util/url \
 -u "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases/$RELEASE_ID/assets" \
 -o "$ARTIFACT" \
 || . ex/util/throw 101 "Get release $RELEASE_ID assets error [$?]: $(cat "$ARTIFACT")!"

ASSETS_BEFORE=$(jq length assemble/github/release/assets.before.json)
echo "asset data: $(date +%s%N)" > "/tmp/$ISSUE_NAME"
ISSUE_NAME_2="asset$(date +%s%N)_foo.txt"
echo "asset data: $(date +%s%N) foo" > "/tmp/$ISSUE_NAME_2"
ASSETS='[]'
ASSET='{}'
. ex/util/json_merge -v ASSET \
 ".name=\"$ISSUE_NAME\"" \
 ".label=\"$ISSUE_NAME\"" \
 ".path=\"/tmp/$ISSUE_NAME\""
. ex/util/json_merge -v ASSETS ".+=[$ASSET]"
ASSET='{}'
. ex/util/json_merge -v ASSET \
 ".name=\"$ISSUE_NAME_2\"" \
 ".label=\"$ISSUE_NAME_2\"" \
 ".path=\"/tmp/$ISSUE_NAME_2\""
. ex/util/json_merge -v ASSETS ".+=[$ASSET]"
$SCRIPT "$ASSETS"; . ex/util/assert -eqv $? 0

ARTIFACT="assemble/github/release/assets.after.json"
MAX_INDEX=8
for ((TRY_INDEX=0; TRY_INDEX<MAX_INDEX; TRY_INDEX++)); do
 rm "$ARTIFACT"
 ex/util/url \
  -u "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases/$RELEASE_ID/assets" \
  -o "$ARTIFACT" \
  || . ex/util/throw 101 "Illegal state!"
 ASSETS_AFTER=$(jq -Mcer length "$ARTIFACT") \
  || . ex/util/throw 101 "Illegal state!"
 [ "$ASSETS_AFTER" == "$((ASSETS_BEFORE + 2))" ] && break
 echo "The check failed for the $((TRY_INDEX + 1))/$MAX_INDEX time..."
 [ $TRY_INDEX == $((MAX_INDEX - 1)) ] \
  && . ex/util/throw 102 "The pull request #$PR_NUMBER comments is not expected!"
 sleep 3
done

exit 0
