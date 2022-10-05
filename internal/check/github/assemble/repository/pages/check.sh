#!/bin/bash

echo "
Check error..."

EXPECTED=101
ACTUAL=0
ex/github/assemble/repository/pages.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi

echo "
Check success..."

VCS_DOMAIN='https://api.github.com'
VCS_PAT="$GITHUB_PAT"
REPOSITORY_OWNER='kepocnhh'
REPOSITORY_NAME='useless'
CI_BUILD_ID=2989462289
. ex/github/assemble/actions/run.sh
. ex/github/assemble/repository.sh
. ex/github/assemble/repository/pages.sh

ARTIFACT='assemble/vcs/repository/pages.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 21
fi

if test "$(jq -r .url "$ARTIFACT")" != "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/pages"; then
 echo "Actual repository pages url error!"
 exit 31
fi
