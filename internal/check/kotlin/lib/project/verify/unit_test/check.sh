#!/bin/bash

SCRIPT='ex/kotlin/lib/project/verify/unit_test.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 152

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
JSON_FILE="$JSON_PATH/verify/unit_test.json"
[ -f "$JSON_FILE" ] && . ex/util/throw 101 "File \"$JSON_FILE\" exists!"
$SCRIPT; . ex/util/assert -eqv $? 122

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='kepocnhh'
export REPOSITORY_NAME='useless'

. ex/util/pipeline ex/github/assemble/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

GIT_BRANCH_SRC='eef05bd33d8a747011fd8435c64d965287ccb8fc'

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 102 "Illegal state!"

. ex/util/assert -s "$JSON_FILE"
rm "$JSON_FILE"
[ -f "$JSON_FILE" ] && . ex/util/throw 103 "File \"$JSON_FILE\" exists!"
$SCRIPT; . ex/util/assert -eqv $? 122

echo 'foo' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{"UNIT_TEST": {}}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{"UNIT_TEST": {"task":"clean"}}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{"UNIT_TEST": {"task":"clean"}, "TEST_COVERAGE": {}}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{"UNIT_TEST": {"task":"clean"}, "TEST_COVERAGE": {"task":"clean"}}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{"UNIT_TEST": {"task":"clean"}, "TEST_COVERAGE": {"task":"clean", "verification": {}}}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

GIT_BRANCH_SRC='83dc3e5746eb7eaaa7dbe00bd1e0d4948f6e0717' # unit test problem

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 104 "Illegal state!"

$SCRIPT; . ex/util/assert -eqv $? 21

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

GIT_BRANCH_SRC='00867e6805c8e2b54eea7b91b0f4990b148d4dc3' # unit test coverage problem

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 105 "Illegal state!"

$SCRIPT; . ex/util/assert -eqv $? 22

echo "
Check success..."

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

GIT_BRANCH_SRC='eef05bd33d8a747011fd8435c64d965287ccb8fc' # snapshot

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 106 "Illegal state!"

. $SCRIPT

exit 0
