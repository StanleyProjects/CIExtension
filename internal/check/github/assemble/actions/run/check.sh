#!/bin/bash

echo "
Check error..."

EXPECTED=101
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi
export VCS_DOMAIN='1'
EXPECTED=102
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 102
fi
export REPOSITORY_OWNER='2'
EXPECTED=103
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 103
fi
export REPOSITORY_NAME='3'
EXPECTED=104
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 104
fi

export CI_BUILD_ID='a'
EXPECTED=21
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 104
fi

VCS_DOMAIN='https://api.github.com'
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 105
fi

REPOSITORY_OWNER='kepocnhh'
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 105
fi

REPOSITORY_NAME='useless'
ACTUAL=0
ex/github/assemble/actions/run.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 105
fi

echo "
Check success..."

CI_BUILD_ID=2989462289

. ex/github/assemble/actions/run.sh

ARTIFACT='assemble/vcs/actions/run.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 21
fi

if test "$(jq -r .repository.name "$ARTIFACT")" != "$REPOSITORY_NAME"; then
 echo "Actual repository name error!"
 exit 31
fi

if test "$(jq -r .repository.owner.login "$ARTIFACT")" != "$REPOSITORY_OWNER"; then
 echo "Actual repository owner login error!"
 exit 32
fi

if test "$(jq .id "$ARTIFACT")" != "$CI_BUILD_ID"; then
 echo "Actual ID error!"
 exit 33
fi

if test "$(jq .run_number "$ARTIFACT")" != '56'; then
 echo "Actual run number error!"
 exit 34
fi
