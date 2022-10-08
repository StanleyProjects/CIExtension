#!/bin/bash

SCRIPT='ex/github/diagnostics/report.sh'
if [ ! -s "$SCRIPT" ]; then
 echo "Script \"$SCRIPT\" does not exist!"
 error 1
fi

echo "
Check error..."

EXPECTED=101
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi

export VCS_PAT="$CHECK_VCS_PAT"

EXPECTED=122
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 102
fi

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

EXPECTED=122
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 103
fi

. ex/github/assemble/actions/run/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

GIT_BRANCH_SRC='f41e7ff3a2a066f21ebbe94f0a6adfe5031dd838'

git -C "$REPOSITORY" init && \
 git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" && \
 git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" && \
 git -C "$REPOSITORY" checkout FETCH_HEAD || exit 1

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
. ex/util/mkdirs diagnostics
echo "{}" > diagnostics/summary.json

EXPECTED=22
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 104
fi

rm -rf pages/diagnostics/report

. ex/kotlin/lib/project/diagnostics/common.sh \
 "$JSON_PATH/verify/common.json"

EXPECTED=122
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 104
fi

rm -rf pages/diagnostics/report

. ex/github/assemble/worker.sh

echo "
Check success..."

exit 1 # todo
