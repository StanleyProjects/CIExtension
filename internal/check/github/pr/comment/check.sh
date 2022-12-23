#!/bin/bash

SCRIPT='ex/github/pr/comment.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 11
[ ! -z "$VCS_PAT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 101
export VCS_PAT='foo'
[ ! -z "$PR_NUMBER" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 102
export PR_NUMBER='foo'
[ -f assemble/vcs/repository.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 122
. ex/util/mkdirs assemble/vcs
touch assemble/vcs/repository.json
$SCRIPT 1; . ex/util/assert -eqv $? 123
echo 'foo' > assemble/vcs/repository.json
$SCRIPT 1; . ex/util/assert -eqv $? 42
echo '{}' > assemble/vcs/repository.json
$SCRIPT 1; . ex/util/assert -eqv $? 42
. ex/util/json_merge -f assemble/vcs/repository.json \
 '.url="bar"'
$SCRIPT 1; . ex/util/assert -eqv $? 21

echo "
Check success..."

VCS_PAT="$CHECK_VCS_PAT"
[ -z "$VCS_PAT" ] && . ex/util/throw 101 "Illegal state!"
VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
REPOSITORY_URL="$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME"
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$REPOSITORY_URL\""
PR_NUMBER=15

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
ex/github/assemble/pr.sh || . ex/util/throw 101 "Illegal state!"
. ex/util/json -f "$ARTIFACT" -si '.comments' COMMENTS_BEFORE

COMMENT="comment $(date +%s%N)"
$SCRIPT "$COMMENT"; . ex/util/assert -eqv $? 0

MAX_INDEX=8
for ((TRY_INDEX=0; TRY_INDEX<MAX_INDEX; TRY_INDEX++ )); do
 rm "$ARTIFACT"
 ex/github/assemble/pr.sh || . ex/util/throw 101 "Illegal state!"
 . ex/util/json -f "$ARTIFACT" -si '.comments' COMMENTS_AFTER
 ex/util/assert -eqv "$COMMENTS_AFTER" "$((COMMENTS_BEFORE + 1))" && break
 echo "The check failed for the $((TRY_INDEX + 1))/$MAX_INDEX time..."
 [ $TRY_INDEX == $((MAX_INDEX - 1)) ] \
  && . ex/util/throw 102 "The pull request #$PR_NUMBER comments is not expected!"
 sleep 3
done

COMMENTS_PER_PAGE=30
COMMENTS_PAGE=$(((COMMENTS_AFTER / COMMENTS_PER_PAGE) + 1))
COMMENTS_IN_PAGE=$((COMMENTS_AFTER - (COMMENTS_PER_PAGE * (COMMENTS_PAGE - 1))))
. ex/util/json -f "$ARTIFACT" -sfs ".comments_url" COMMENTS_URL
. ex/util/mkdirs "assemble/vcs/pr${PR_NUMBER}"
ARTIFACT="assemble/vcs/pr${PR_NUMBER}/comments.json"
for ((TRY_INDEX=0; TRY_INDEX<MAX_INDEX; TRY_INDEX++ )); do
 rm "$ARTIFACT"
 ex/util/url -u "$COMMENTS_URL?per_page=$COMMENTS_PER_PAGE&page=$COMMENTS_PAGE&sort=created" -o "$ARTIFACT" \
  || . ex/util/throw 21 "Get pull request #$PR_NUMBER comments error!"
 COMMENTS_ACTUAL="$(jq 'length' "$ARTIFACT")"
 . ex/util/require COMMENTS_ACTUAL
 ex/util/assert -eqv "$COMMENTS_ACTUAL" "$COMMENTS_IN_PAGE" && break
 echo "The check failed for the $((TRY_INDEX + 1))/$MAX_INDEX time..."
 [ $TRY_INDEX == $((MAX_INDEX - 1)) ] \
  && . ex/util/throw 103 "The pull request #$PR_NUMBER comments is not expected!"
 sleep 3
done

COMMENT_BODY="$(jq ".[$((COMMENTS_IN_PAGE - 1))]" "$ARTIFACT")"

. ex/util/require COMMENT_BODY
. ex/util/json -j "$COMMENT_BODY" -sfs '.issue_url' ACTUAL_VALUE
. ex/util/assert -eqv "$ACTUAL_VALUE" "$REPOSITORY_URL/issues/$PR_NUMBER"
. ex/util/json -j "$COMMENT_BODY" -sfs '.body' ACTUAL_VALUE

. ex/util/assert -eq ACTUAL_VALUE COMMENT

exit 0
