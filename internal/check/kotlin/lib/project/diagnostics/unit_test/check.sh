#!/bin/bash

SCRIPT='ex/kotlin/lib/project/diagnostics/unit_test.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 152

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
JSON_FILE="$JSON_PATH/verify/unit_test.json"
[ -f "$JSON_FILE" ] && . ex/util/throw 102 "File \"$JSON_FILE\" exists!"
$SCRIPT; . ex/util/assert -eqv $? 121

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='kepocnhh'
export REPOSITORY_NAME='useless'

. ex/util/pipeline ex/github/assemble/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

GIT_BRANCH_SRC='eef05bd33d8a747011fd8435c64d965287ccb8fc' # snapshot

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

. ex/util/assert -s "$JSON_FILE"
rm "$JSON_FILE"
[ -f "$JSON_FILE" ] && . ex/util/throw 102 "File \"$JSON_FILE\" exists!"
$SCRIPT; . ex/util/assert -eqv $? 121

echo 'foo' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{}' > "$JSON_FILE"
$SCRIPT; . ex/util/assert -eqv $? 42

QUERIES=(
 '.UNIT_TEST={}' '.UNIT_TEST.task="clean"' '.UNIT_TEST.title="foo"'
 '.TEST_COVERAGE={}' '.TEST_COVERAGE.task="clean"' '.TEST_COVERAGE.title="foo"'
 '.TEST_COVERAGE.verification={}'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -f "$JSON_FILE" "${QUERIES[$QUERY_INDEX]}"
 $SCRIPT; . ex/util/assert -eqv $? 42
done

FAILED_TASK="task$(date +%s)"
gradle -q -p "$REPOSITORY" "$FAILED_TASK" && . ex/util/throw 101 "Illegal state!"
echo '{}' > "$JSON_FILE"
QUERIES=(
 '.UNIT_TEST={}' ".UNIT_TEST.task=\"$FAILED_TASK\"" '.UNIT_TEST.path="foo"'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -f "$JSON_FILE" "${QUERIES[$QUERY_INDEX]}"
 $SCRIPT; . ex/util/assert -eqv $? 42
done

echo '{}' > "$JSON_FILE"
QUERIES=(
 '.UNIT_TEST={}' '.UNIT_TEST.task="clean"' '.UNIT_TEST.title="foo"'
 '.TEST_COVERAGE={}' '.TEST_COVERAGE.task="clean"' '.TEST_COVERAGE.title="foo"'
 '.TEST_COVERAGE.verification={}' ".TEST_COVERAGE.verification.task=\"$FAILED_TASK\"" '.TEST_COVERAGE.path="foo"'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -f "$JSON_FILE" "${QUERIES[$QUERY_INDEX]}"
 $SCRIPT; . ex/util/assert -eqv $? 42
done
echo '{}' > "$JSON_FILE"
. ex/util/json_merge -f "$JSON_FILE" \
 '.UNIT_TEST.task="clean"' \
 '.UNIT_TEST.title="foo"' \
 ".TEST_COVERAGE.task=\"$FAILED_TASK\"" \
 '.TEST_COVERAGE.title="foo"'
$SCRIPT; . ex/util/assert -eqv $? 31

echo "
Check success..."

. ex/util/mkdirs diagnostics

GIT_BRANCH_SRC='eef05bd33d8a747011fd8435c64d965287ccb8fc' # snapshot

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

ARTIFACT=diagnostics/summary.json
echo '{}' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$ARTIFACT"
. ex/util/assert -eqv "$(jq -Mcer keys "$ARTIFACT")" '[]'

GIT_BRANCH_SRC='83dc3e5746eb7eaaa7dbe00bd1e0d4948f6e0717' # unit test problem

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

ARTIFACT=diagnostics/summary.json
echo '{}' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$ARTIFACT"
. ex/util/assert -eqv "$(jq -Mcer keys "$ARTIFACT")" '["UNIT_TEST"]'

GIT_BRANCH_SRC='00867e6805c8e2b54eea7b91b0f4990b148d4dc3' # unit test coverage problem

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

ARTIFACT=diagnostics/summary.json
echo '{}' > "$ARTIFACT"
$SCRIPT; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$ARTIFACT"
. ex/util/assert -eqv "$(jq -Mcer keys "$ARTIFACT")" '["TEST_COVERAGE"]'

exit 0
