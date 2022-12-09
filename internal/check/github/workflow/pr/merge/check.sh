#!/bin/bash

SCRIPT='ex/github/workflow/pr/merge.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export PR_NUMBER='foo'

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
[ -f "$ARTIFACT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 122

. ex/util/mkdirs assemble/vcs
echo '{}' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 42

. ex/util/json_merge -f "$ARTIFACT" \
 '.head.sha="bar"' \
 '.base.ref="foo"'
[ -f assemble/vcs/worker.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 122

echo '{}' > assemble/vcs/worker.json
$SCRIPT; . ex/util/assert -eqv $? 42

. ex/util/json_merge -f assemble/vcs/worker.json \
 '.name="foo"' \
 '.vcs_email="bar"'
REPOSITORY='repository'
[ -d "$REPOSITORY" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 152

. ex/util/mkdirs "$REPOSITORY"
$SCRIPT; . ex/util/assert -eqv $? 21

GIT_COMMIT_SRC='538b3f463ca5395c125b1616f4b30452f31cc0dc'

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='StanleyProjects'
export REPOSITORY_NAME='CIExtension'

. ex/util/pipeline ex/github/assemble/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_COMMIT_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

GIT_BRANCH_DST="sha$(date +%s)"
git -C "$REPOSITORY" fetch origin "$GIT_BRANCH_DST" \
 && . ex/util/throw 101 "Illegal state!"

. ex/util/json_merge -f "$ARTIFACT" \
 ".head.sha=\"$GIT_COMMIT_SRC\"" \
 ".base.ref=\"$GIT_BRANCH_DST\""
$SCRIPT; . ex/util/assert -eqv $? 22

echo "
Check success..."

GIT_BRANCH_DST='1d19078f472b531b0263bdc6a95983bb6dc8ff9b'
. ex/util/json_merge -f "$ARTIFACT" \
 ".base.ref=\"$GIT_BRANCH_DST\""

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_COMMIT_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

QUERIES=(
 'github/tag/test'
 'kotlin/lib/project/assemble/common'
 'kotlin/lib/project/diagnostics/common'
 'kotlin/lib/project/diagnostics/unit_test'
 'kotlin/lib/project/prepare'
 'kotlin/lib/project/verify/common'
 'kotlin/lib/project/verify/pre'
 'kotlin/lib/project/verify/unit_test'
 'util/json_merge'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 TYPE="${QUERIES[$QUERY_INDEX]}"
 [ -f "${REPOSITORY}/internal/check/${TYPE}/Dockerfile" ] && . ex/util/throw 101 "Illegal state!"
 [ -f "${REPOSITORY}/internal/check/${TYPE}/build.sh" ] && . ex/util/throw 101 "Illegal state!"
 [ -f "${REPOSITORY}/internal/check/${TYPE}/check.sh" ] && . ex/util/throw 101 "Illegal state!"
done
$SCRIPT; . ex/util/assert -eqv $? 0
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 TYPE="${QUERIES[$QUERY_INDEX]}"
 . ex/util/assert -s \
  "${REPOSITORY}/internal/check/${TYPE}/Dockerfile" \
  "${REPOSITORY}/internal/check/${TYPE}/build.sh" \
  "${REPOSITORY}/internal/check/${TYPE}/check.sh"
done

exit 0
