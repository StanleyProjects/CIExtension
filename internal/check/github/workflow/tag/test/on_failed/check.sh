#!/bin/bash

SCRIPT='ex/github/workflow/tag/test/on_failed.sh'
. ex/util/assert -s "$SCRIPT"

echo '
Check error...'

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

[ ! -z "$PR_NUMBER" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 101

export PR_NUMBER='foo'
[ ! -z "$VCS_PAT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 21

export VCS_PAT="$CHECK_VCS_PAT"
$SCRIPT 1; . ex/util/assert -eqv $? 21

. ex/util/mkdirs assemble/vcs/commit
echo '{}' > assemble/vcs/repository.json
export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='StanleyProjects'
export REPOSITORY_NAME='CIExtension'
REPOSITORY_URL="$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME"
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$REPOSITORY_URL\""
PR_NUMBER=16

BODY='{}'
. ex/util/json_merge -v BODY '.state="open"'
curl -s -f -X PATCH "$REPOSITORY_URL/pulls/$PR_NUMBER" -H "Authorization: token $VCS_PAT" -d "$BODY" > /dev/null \
 || . ex/util/throw 101 'Illegal state!'

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
curl -f "$REPOSITORY_URL/pulls/$PR_NUMBER" > "$ARTIFACT" \
 || . ex/util/throw 101 'Illegal state!'
. ex/util/assert -eqv "$(jq -r '.state' "$ARTIFACT")" 'open'

$SCRIPT 1; . ex/util/assert -eqv $? 122

export CI_BUILD_ID=3725351508
ex/github/assemble/actions/run.sh \
 || . ex/util/throw 101 'Illegal state!'

rm assemble/vcs/repository.json
ex/github/assemble/actions/run/repository.sh \
 || . ex/util/throw 101 'Illegal state!'

$SCRIPT 1; . ex/util/assert -eqv $? 122

ex/github/assemble/repository/owner.sh \
 || . ex/util/throw 101 'Illegal state!'

$SCRIPT 1; . ex/util/assert -eqv $? 122

ex/github/assemble/pr/commit.sh \
 || . ex/util/throw 101 'Illegal state!'

$SCRIPT 1; . ex/util/assert -eqv $? 122

ex/github/assemble/worker.sh \
 || . ex/util/throw 101 'Illegal state!'

echo '
Check success...'

export TELEGRAM_BOT_ID=$CHECK_TELEGRAM_BOT_ID
export TELEGRAM_BOT_TOKEN=$CHECK_TELEGRAM_BOT_TOKEN
export TELEGRAM_CHAT_ID=$CHECK_TELEGRAM_CHAT_ID
. ex/util/require TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID

$SCRIPT 1; . ex/util/assert -eqv $? 0

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
