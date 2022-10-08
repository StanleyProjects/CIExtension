#!/bin/bash

SCRIPT='ex/kotlin/lib/project/assemble/common.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 152

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

$SCRIPT; . ex/util/assert -eqv $? 11

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='kepocnhh'
export REPOSITORY_NAME='useless'

. ex/util/pipeline ex/github/assemble/repository.sh

REPOSITORY_JSON=/tmp/repository.json
mv assemble/vcs/repository.json "$REPOSITORY_JSON"
ex/util/assert -f assemble/vcs/repository.json && . ex/util/throw 101 "Illegal state!"

. ex/util/json -f "$REPOSITORY_JSON" \
 -sfs .owner.login REPOSITORY_OWNER_LOGIN \
 -sfs .clone_url REPOSITORY_CLONE_URL

GIT_BRANCH_SRC='f41e7ff3a2a066f21ebbe94f0a6adfe5031dd838'

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 102 "Illegal state!"

ARTIFACT="$REPOSITORY/build/common.json"

$SCRIPT; . ex/util/assert -eqv $? 122
. ex/util/assert -s "$ARTIFACT"
rm "$ARTIFACT"
ex/util/assert -f "$ARTIFACT" && . ex/util/throw 201 "Illegal state!"

rm assemble/vcs/repository.json
ex/util/assert -f assemble/vcs/repository.json && . ex/util/throw 121 "Illegal state!"
echo "{}" > assemble/vcs/repository.json
. ex/util/assert -s assemble/vcs/repository.json

$SCRIPT; . ex/util/assert -eqv $? 42
. ex/util/assert -s "$ARTIFACT"
rm "$ARTIFACT"
ex/util/assert -f "$ARTIFACT" && . ex/util/throw 201 "Illegal state!"

. ex/util/json_merge -f assemble/vcs/repository.json \
 ".owner.login=\"$(date +%s)\""

$SCRIPT; . ex/util/assert -eqv $? 1
. ex/util/assert -s "$ARTIFACT"
rm "$ARTIFACT"
ex/util/assert -f "$ARTIFACT" && . ex/util/throw 201 "Illegal state!"

exit 1 # todo

echo "
Check success..."

ex/util/assert -f "$ARTIFACT" && . ex/util/throw 104 "Illegal state!"

. $SCRIPT

. ex/util/assert -s "$ARTIFACT"

. ex/util/json -f "$ARTIFACT" \
 -sfs .repository.owner ACTUAL_OWNER \
 -sfs .repository.name ACTUAL_NAME

. ex/util/assert -eq REPOSITORY_OWNER_LOGIN ACTUAL_OWNER
. ex/util/assert -eq REPOSITORY_NAME ACTUAL_NAME
