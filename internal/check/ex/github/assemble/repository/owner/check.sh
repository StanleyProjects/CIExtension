#!/bin/bash

echo "
Check error..."

EXPECTED=122
ACTUAL=0
ex/github/assemble/repository/owner.sh; ACTUAL=$?
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
. ex/github/assemble/repository/owner.sh

ARTIFACT='assemble/vcs/repository/owner.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 21
fi

if test "$(jq .id "$ARTIFACT")" != '6218886'; then
 echo "Actual repository owner id error!"
 exit 31
fi

if test "$(jq -r .login "$ARTIFACT")" != "$REPOSITORY_OWNER"; then
 echo "Actual repository owner login error!"
 exit 32
fi
