#!/bin/bash

SCRIPT='ex/github/assemble/repository/pages.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export VCS_PAT="$CHECK_VCS_PAT"
[ -z "$VCS_PAT" ] && . ex/util/throw 101 "Illegal state!"

$SCRIPT; . ex/util/assert -eqv $? 122

echo "
Check success..."

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='kepocnhh'
REPOSITORY_NAME='useless'
. ex/github/assemble/repository.sh
$SCRIPT; . ex/util/assert -eqv $? 0

ARTIFACT='assemble/vcs/repository/pages.json'
. ex/util/assert -s "$ARTIFACT"
. ex/util/assert -eqv "$(jq -r .url "$ARTIFACT")" "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/pages"
