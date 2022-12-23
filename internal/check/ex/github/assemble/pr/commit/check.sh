#!/bin/bash

SCRIPT='ex/github/assemble/pr/commit.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

[ -f assemble/vcs/repository.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 122
. ex/util/mkdirs assemble/vcs
touch assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 123
echo 'foo' > assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{}' > assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 42

. ex/util/json_merge -f assemble/vcs/repository.json \
 '.url="foo"'
[ ! -z "$VCS_DOMAIN" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 101
export VCS_DOMAIN='bar'
[ ! -z "$PR_NUMBER" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 102

export PR_NUMBER='foo'
ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
[ -f "$ARTIFACT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT; . ex/util/assert -eqv $? 122
touch "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 123
echo 'foo' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{}' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 42
. ex/util/json_merge -f "$ARTIFACT" \
 '.head.sha="foo"'
$SCRIPT; . ex/util/assert -eqv $? 42
. ex/util/json_merge -f "$ARTIFACT" \
 '.base.sha="foo"'
$SCRIPT; . ex/util/assert -eqv $? 21

echo "
Check success..."

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
REPOSITORY_URL="$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME"
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$REPOSITORY_URL\""
rm "$ARTIFACT"
PR_NUMBER=15
ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
touch "$ARTIFACT"
echo '{}' > "$ARTIFACT"
GIT_COMMIT_SRC='97d4474057d52d95e4c86ca97aa5789ad94c0069'
GIT_COMMIT_DST='464c8475fb805f2dd7b90a90e4dfb8afe32939e7'
. ex/util/json_merge -f "$ARTIFACT" \
 ".head.sha=\"$GIT_COMMIT_SRC\"" \
 ".base.sha=\"$GIT_COMMIT_DST\""

$SCRIPT; . ex/util/assert -eqv $? 0

. ex/util/assert -s assemble/vcs/commit.src.json
. ex/util/assert -s assemble/vcs/commit/author.src.json
. ex/util/assert -s assemble/vcs/commit.dst.json
. ex/util/assert -s assemble/vcs/commit/author.dst.json

ARTIFACT='assemble/vcs/commit.src.json'
. ex/util/json -f "$ARTIFACT" -sfs ".sha" ACTUAL_VALUE
. ex/util/assert -eq ACTUAL_VALUE GIT_COMMIT_SRC

ARTIFACT='assemble/vcs/commit.dst.json'
. ex/util/json -f "$ARTIFACT" -sfs ".sha" ACTUAL_VALUE
. ex/util/assert -eq ACTUAL_VALUE GIT_COMMIT_DST

exit 0
