#!/bin/bash

echo "
Check error..."

EXPECTED=122
ACTUAL=0
ex/github/assemble/repository.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi

echo "
Check success..."

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='kepocnhh'
REPOSITORY_NAME='useless'
CI_BUILD_ID=2989462289
. ex/github/assemble/actions/run.sh
. ex/github/assemble/repository.sh

ARTIFACT='assemble/vcs/repository.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 21
fi

if test "$(jq -r .name "$ARTIFACT")" != "$REPOSITORY_NAME"; then
 echo "Actual repository name error!"
 exit 31
fi

if test "$(jq -r .owner.login "$ARTIFACT")" != "$REPOSITORY_OWNER"; then
 echo "Actual repository owner login error!"
 exit 32
fi
