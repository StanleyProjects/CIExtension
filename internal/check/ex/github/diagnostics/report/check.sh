#!/bin/bash

SCRIPT='ex/github/diagnostics/report.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export VCS_PAT="$CHECK_VCS_PAT"

$SCRIPT; . ex/util/assert -eqv $? 121

. ex/util/mkdirs diagnostics
echo "$(date +%s)" > diagnostics/summary.json

export VCS_DOMAIN='https://api.github.com'
CHECK_REPOSITORY_NAME='useless'

. ex/util/mkdirs assemble/vcs/actions
echo "{
 \"id\": -$(date +"%Y%m%d%H%M%S"),
 \"run_number\": -$(date +"%Y%m%d%H%M"),
 \"repository\": {
  \"url\": \"$VCS_DOMAIN/repos/kepocnhh/$CHECK_REPOSITORY_NAME\",
  \"name\": \"$CHECK_REPOSITORY_NAME\"
 }
}" > assemble/vcs/actions/run.json

$SCRIPT; . ex/util/assert -eqv $? 122

. ex/util/pipeline ex/github/assemble/actions/run/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

GIT_BRANCH_SRC='f41e7ff3a2a066f21ebbe94f0a6adfe5031dd838'

git -C "$REPOSITORY" init && \
 git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" && \
 git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" && \
 git -C "$REPOSITORY" checkout FETCH_HEAD || . ex/util/throw 101 "Illegal state!"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"

$SCRIPT; . ex/util/assert -eqv $? 122

. ex/util/pipeline ex/github/assemble/repository/pages.sh

echo "
bad json..."
echo 'foo' > diagnostics/summary.json
$SCRIPT; . ex/util/assert -eqv $? 21

echo "
empty json..."
echo '{}' > diagnostics/summary.json
$SCRIPT; . ex/util/assert -eqv $? 22

echo "
empty report dir..."
echo '{"FOO":"foo"}' > diagnostics/summary.json
$SCRIPT; . ex/util/assert -eqv $? 32

echo "
no worker..."
rm -rf pages/diagnostics/report
. ex/util/mkdirs "diagnostics/report/dir$(date +%s)"
$SCRIPT; . ex/util/assert -eqv $? 122

echo "
Check success..."

. ex/util/pipeline ex/github/assemble/worker.sh

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin 'ea5c3000794cad3a469b23b16343e7934a9bf176' \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"
rm -rf diagnostics
. ex/util/mkdirs diagnostics
echo '{}' > diagnostics/summary.json
JSON_FILE="$JSON_PATH/verify/common.json"
. ex/util/assert -s "$JSON_FILE"

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .id CI_BUILD_ID \
 -si .run_number CI_BUILD_NUMBER

echo "
diagnostics..."
echo '{}' > diagnostics/summary.json
for it in 'foo' 'bar' 'baz'; do
 . ex/util/json_merge -f diagnostics/summary.json \
  ".$it.path=\"$it\"" \
  ".$it.title=\"$it\""
 . ex/util/mkdirs "diagnostics/report/$it"
 echo "$it" > "diagnostics/report/$it/index.html"
done

TAG="diagnostics/report/$CI_BUILD_NUMBER/$CI_BUILD_ID"
. ex/github/tag/test.sh "$TAG"

rm -rf pages/diagnostics/report
$SCRIPT || . ex/util/throw 101 "Illegal state!"

TRY_NUMBER=1
TRY_MAX=10
while :; do
 echo "try [${TRY_NUMBER}/$TRY_MAX]..."
 ex/github/tag/test.sh "$TAG" || break
 [ $TRY_NUMBER -gt $TRY_MAX ] && . ex/util/throw 102 "The maximum number of attempts ($TRY_MAX) has been reached!"
 sleep 2
 TRY_NUMBER=$((TRY_NUMBER + 1))
done

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$TAG" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

TYPES=($(jq -Mcer 'keys|.[]' diagnostics/summary.json)) \
 || . ex/util/throw 101 "Illegal state!"
TYPES_SIZE=${#TYPES[*]}
for ((TYPE_INDEX=0; TYPE_INDEX<$TYPES_SIZE; TYPE_INDEX++)); do
 TYPE="${TYPES[TYPE_INDEX]}"
 . ex/util/json -f diagnostics/summary.json \
  -sfs ".${TYPE}.path" RELATIVE
 . ex/util/assert -s "$REPOSITORY/build/$CI_BUILD_NUMBER/$CI_BUILD_ID/diagnostics/report/$RELATIVE/index.html"
done
