#!/bin/bash

echo "
Check error..."

EXPECTED=101
ACTUAL=0
ex/github/assemble/repository.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi

export VCS_DOMAIN='https://api.github.com'

EXPECTED=102
ACTUAL=0
ex/github/assemble/repository.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 102
fi

export REPOSITORY_OWNER='kepocnhh'

EXPECTED=103
ACTUAL=0
ex/github/assemble/repository.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 103
fi

echo "
Check success..."

REPOSITORY_NAME='useless'
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

if test "$(jq .id "$ARTIFACT")" != '498710088'; then
 echo "Actual repository id error!"
 exit 33
fi
