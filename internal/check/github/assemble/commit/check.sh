#!/bin/bash

SCRIPT='ex/github/assemble/commit.sh'
if [ ! -s "$SCRIPT" ]; then
 echo "Script \"$SCRIPT\" does not exist!"
 error 1
fi

echo "
Check error..."

EXPECTED=11
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 21
fi

REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
COMMIT_SHA='16a444fa8ca2b2fdfb3d79ec46a9c84de1c825f7'

mkdir repository
git -C repository init \
 && git -C repository remote add origin https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME.git \
 && git -C repository fetch --depth=1 origin "$COMMIT_SHA" \
 && git -C repository checkout FETCH_HEAD || exit 101

EXPECTED=122
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 22
fi

echo "
Check success..."

VCS_DOMAIN='https://api.github.com'
. ex/github/assemble/repository.sh
. $SCRIPT

ARTIFACT='assemble/vcs/commit.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 201
fi

if test "$(jq -r .sha "$ARTIFACT")" != "$COMMIT_SHA"; then
 echo "Actual commit sha error!"
 exit 202
fi

if test "$(jq -r .url "$ARTIFACT")" != "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/commits/$COMMIT_SHA"; then
 echo "Actual commit sha error!"
 exit 203
fi

ARTIFACT='assemble/vcs/commit/author.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 211
fi

if test "$(jq -r .login "$ARTIFACT")" != "$(jq -r .author.login assemble/vcs/commit.json)"; then
 echo "Actual commit author login error!"
 exit 212
fi
