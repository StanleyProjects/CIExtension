#!/bin/bash

SCRIPT='ex/github/assemble/commit.sh'
. ex/util/assert -s "$SCRIPT"

echo '
Check error...'

$SCRIPT; . ex/util/assert -eqv $? 152

. ex/util/mkdirs repository

$SCRIPT; . ex/util/assert -eqv $? 11

REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
COMMIT_SHA='16a444fa8ca2b2fdfb3d79ec46a9c84de1c825f7'

git -C repository init \
 && git -C repository remote add origin "https://github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}.git" \
 && git -C repository fetch --depth=1 origin "$COMMIT_SHA" \
 && git -C repository checkout FETCH_HEAD || exit 101

$SCRIPT; . ex/util/assert -eqv $? 122

echo '
Check success...'

VCS_DOMAIN='https://api.github.com'
. ex/github/assemble/repository.sh
. $SCRIPT

ARTIFACT='assemble/vcs/commit.json'
. ex/util/assert -s "$ARTIFACT"

. ex/util/assert -eqv "$(jq -r .sha "$ARTIFACT")" "$COMMIT_SHA"
. ex/util/assert -eqv "$(jq -r .url "$ARTIFACT")" "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/commits/$COMMIT_SHA"

ARTIFACT='assemble/vcs/commit/author.json'
. ex/util/assert -s "$ARTIFACT"

. ex/util/assert -eqv "$(jq -r .login "$ARTIFACT")" "$(jq -r .author.login assemble/vcs/commit.json)"
