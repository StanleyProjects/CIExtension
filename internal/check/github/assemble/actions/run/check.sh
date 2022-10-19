#!/bin/bash

SCRIPT='ex/github/assemble/actions/run.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export VCS_DOMAIN='1'
$SCRIPT; . ex/util/assert -eqv $? 102

export REPOSITORY_OWNER='2'
$SCRIPT; . ex/util/assert -eqv $? 103

export REPOSITORY_NAME='3'
$SCRIPT; . ex/util/assert -eqv $? 104

export CI_BUILD_ID='a'
$SCRIPT; . ex/util/assert -eqv $? 21

ARTIFACT='assemble/vcs/actions/run.json'
[ -f "$ARTIFACT" ] && . ex/util/throw 102 "File \"$ARTIFACT\" exists!"
VCS_DOMAIN='https://api.github.com'
$SCRIPT; . ex/util/assert -eqv $? 21
. ex/util/assert -s "$ARTIFACT"

rm "$ARTIFACT"
[ -f "$ARTIFACT" ] && . ex/util/throw 102 "File \"$ARTIFACT\" exists!"
REPOSITORY_OWNER='kepocnhh'
$SCRIPT; . ex/util/assert -eqv $? 21

rm "$ARTIFACT"
[ -f "$ARTIFACT" ] && . ex/util/throw 102 "File \"$ARTIFACT\" exists!"
REPOSITORY_NAME='useless'

echo "
Check success..."

CI_BUILD_ID=2989462289

$SCRIPT; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$ARTIFACT"
. ex/util/assert -eqv "$(jq -r .repository.name "$ARTIFACT")" "$REPOSITORY_NAME"
. ex/util/assert -eqv "$(jq -r .repository.owner.login "$ARTIFACT")" "$REPOSITORY_OWNER"
. ex/util/assert -eqv "$(jq .id "$ARTIFACT")" "$CI_BUILD_ID"
. ex/util/assert -eqv "$(jq .run_number "$ARTIFACT")" 56

exit 0
