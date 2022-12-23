#!/bin/bash

SCRIPT='ex/github/workflow/pr/commit.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export PR_NUMBER='foo'

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
[ -f "$ARTIFACT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 122

. ex/util/mkdirs assemble/vcs/actions
echo '{}' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 42

. ex/util/json_merge -f "$ARTIFACT" \
 '.head.sha="bar"' \
 '.base.sha="foo"'
[ -f assemble/vcs/actions/run.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 122

echo '{}' > assemble/vcs/actions/run.json
$SCRIPT; . ex/util/assert -eqv $? 42

. ex/util/json_merge -f assemble/vcs/actions/run.json \
 '.run_number=42'
REPOSITORY='repository'
[ -d "$REPOSITORY" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 152

. ex/util/mkdirs "$REPOSITORY"
$SCRIPT; . ex/util/assert -eqv $? 21

echo "
Check success..."

GIT_COMMIT_SRC='23c418dc547aa9fc3b509e5a0593e183f0af226a'

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
 && git -C "$REPOSITORY" fetch origin "$GIT_COMMIT_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

GIT_COMMIT_DST='538b3f463ca5395c125b1616f4b30452f31cc0dc'
GIT_BRANCH_DST='check/github/workflow/pr/merge'

. ex/util/json_merge -f "$ARTIFACT" \
 ".head.sha=\"$GIT_COMMIT_SRC\"" \
 ".base.sha=\"$GIT_COMMIT_DST\"" \
 ".base.ref=\"$GIT_BRANCH_DST\""
echo '{}' > assemble/vcs/worker.json
. ex/util/json_merge -f assemble/vcs/worker.json \
 '.name="foo"' \
 '.vcs_email="bar"'
ex/github/workflow/pr/merge.sh; . ex/util/assert -eqv $? 0
$SCRIPT; . ex/util/assert -eqv $? 0

exit 0
