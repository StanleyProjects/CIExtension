#!/bin/bash

SCRIPT='ex/github/pr/close.sh'
. ex/util/assert -s "$SCRIPT"

echo '
Check error...'

[ -z "$VCS_PAT" ] || . ex/util/throw 101 'Illegal state!'
$SCRIPT; . ex/util/assert -eqv $? 101

export VCS_PAT='foo'
[ -z "$PR_NUMBER" ] || . ex/util/throw 101 'Illegal state!'
$SCRIPT; . ex/util/assert -eqv $? 102

export PR_NUMBER='bar'
$SCRIPT; . ex/util/assert -eqv $? 122
. ex/util/mkdirs assemble/vcs
touch assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 123
echo 'foo' > assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{}' > assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 42
. ex/util/json_merge -f assemble/vcs/repository.json \
 '.url="bar"'
$SCRIPT; . ex/util/assert -eqv $? 21

echo '
Check success...'

VCS_PAT="$CHECK_VCS_PAT"
. ex/util/require VCS_PAT
VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
REPOSITORY_URL="$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME"
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$REPOSITORY_URL\""
PR_NUMBER=16

BODY='{}'
. ex/util/json_merge -v BODY '.state="open"'
curl -f -X PATCH "$REPOSITORY_URL/pulls/$PR_NUMBER" -H "Authorization: token $VCS_PAT" -d "$BODY" \
 || . ex/util/throw 101 'Illegal state!'

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
ex/github/assemble/pr.sh || . ex/util/throw 101 'Illegal state!'
. ex/util/assert -eqv "$(jq -r '.state' "$ARTIFACT")" 'open'

$SCRIPT; . ex/util/assert -eqv $? 0

MAX_INDEX=8
for ((TRY_INDEX=0; TRY_INDEX<MAX_INDEX; TRY_INDEX++)); do
 rm "$ARTIFACT"
 ex/github/assemble/pr.sh || . ex/util/throw 101 "Illegal state!"
 . ex/util/json -f "$ARTIFACT" -sfs '.state' STATE_ACTUAL
 [ "$STATE_ACTUAL" == 'closed' ] && break
 echo "The check failed for the $((TRY_INDEX + 1))/$MAX_INDEX time..."
 [ $TRY_INDEX == $((MAX_INDEX - 1)) ] \
  && . ex/util/throw 102 "The pull request #$PR_NUMBER comments is not expected!"
 sleep 3
done

exit 0
