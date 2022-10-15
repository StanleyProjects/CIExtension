#!/bin/bash

SCRIPT='ex/github/diagnostics/report.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export VCS_PAT="$CHECK_VCS_PAT"

$SCRIPT; . ex/util/assert -eqv $? 122

VCS_DOMAIN='https://api.github.com'
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

. ex/github/assemble/actions/run/repository.sh

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
. ex/util/mkdirs diagnostics
echo "{}" > diagnostics/summary.json

$SCRIPT; . ex/util/assert -eqv $? 22

rm -rf pages/diagnostics/report

. ex/kotlin/lib/project/diagnostics/common.sh \
 "$JSON_PATH/verify/common.json"

$SCRIPT; . ex/util/assert -eqv $? 122

rm -rf pages/diagnostics/report

. ex/github/assemble/worker.sh

echo "
Check success..."

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin 'ea5c3000794cad3a469b23b16343e7934a9bf176' \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"
. ex/util/mkdirs diagnostics
echo '{}' > diagnostics/summary.json
JSON_FILE="$JSON_PATH/verify/common.json"
. ex/util/assert -s "$JSON_FILE"
ex/kotlin/lib/project/diagnostics/common.sh \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 "$JSON_PATH/verify/documentation.json"; . ex/util/assert -eqv $? 0

$SCRIPT || . ex/util/throw 101 "Illegal state!"

exit 1 # todo tag test

REPOSITORY=pages/diagnostics/report
rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "diagnostics/report/$CI_BUILD_NUMBER/$CI_BUILD_ID" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

TYPES="$(jq -Mcer keys diagnostics/summary.json)" \
 || . ex/util/throw 21 "Illegal state!"

exit 1 # todo
