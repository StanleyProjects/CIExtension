#!/bin/bash

SCRIPT='ex/kotlin/lib/project/prepare.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 152

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

$SCRIPT; . ex/util/assert -eqv $? 11

echo "
Check success..."

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='kepocnhh'
export REPOSITORY_NAME='useless'

. ex/util/pipeline ex/github/assemble/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

GIT_BRANCH_SRC='f41e7ff3a2a066f21ebbe94f0a6adfe5031dd838'

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

ARTIFACT="$REPOSITORY/lib/build/classes/kotlin/main"
ex/util/assert -d "$ARTIFACT" && . ex/util/throw 102 "Illegal state!"

. $SCRIPT

. ex/util/assert -d "$ARTIFACT"
