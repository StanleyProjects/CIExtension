#!/bin/bash

SCRIPT='ex/github/release/upload/asset.sh'
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
ex/util/url \
 -u "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases/$RELEASE_ID" \
 -o assemble/github/release.json \
 || . ex/util/throw 101 "Illegal state!"
ISSUE_NAME="asset$(date +%s%N).txt"
ISSUE="/tmp/$ISSUE_NAME"
BODY='{}'
$SCRIPT "$BODY"; . ex/util/assert -eqv $? 41

. ex/util/json_merge -v BODY ".name=\"$ISSUE_NAME\""
$SCRIPT "$BODY"; . ex/util/assert -eqv $? 41

. ex/util/json_merge -v BODY ".label=\"$ISSUE_NAME\""
$SCRIPT "$BODY"; . ex/util/assert -eqv $? 41

. ex/util/json_merge -v BODY ".path=\"$ISSUE\""
[ -f "$ISSUE" ] && . ex/util/throw 101 'Illegal state!'
$SCRIPT "$BODY"; . ex/util/assert -eqv $? 121

echo '
Check success...'

ex/util/url \
 -u "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases/$RELEASE_ID/assets" \
 -o assemble/github/release/assets.before.json \
 || . ex/util/throw 101 "Illegal state!"

ASSETS_BEFORE=$(jq length assemble/github/release/assets.before.json)
echo "asset data: $(date +%s%N)" > "$ISSUE"
$SCRIPT "$BODY"; . ex/util/assert -eqv $? 0

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
 [ "$ASSETS_AFTER" == "$((ASSETS_BEFORE + 1))" ] && break
 echo "The check failed for the $((TRY_INDEX + 1))/$MAX_INDEX time..."
 [ $TRY_INDEX == $((MAX_INDEX - 1)) ] \
  && . ex/util/throw 102 "The pull request #$PR_NUMBER comments is not expected!"
 sleep 3
done

exit 0
