#!/bin/bash

SCRIPT='ex/github/assemble/worker.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export VCS_DOMAIN='https://api.github.com'

$SCRIPT; . ex/util/assert -eqv $? 102

echo "
Check success..."

export VCS_PAT="$CHECK_VCS_PAT"
mkdir -p assemble/vcs
$SCRIPT; . ex/util/assert -eqv $? 0

RESULT="/tmp/$(date +%s)"
[ -f "$RESULT" ] && . ex/util/throw "Illegal state!"

curl -f -w %{http_code} -o "$RESULT" "$VCS_DOMAIN/user" \
 -H "Authorization: token $CHECK_VCS_PAT" \
 || . ex/util/throw "Illegal state!"

ARTIFACT='assemble/vcs/worker.json'
. ex/util/assert -s "$ARTIFACT"
. ex/util/assert -eqv "$(jq -r .login "$ARTIFACT")" "$(jq -r .login "$RESULT")"
. ex/util/assert -eqv "$(jq .id "$ARTIFACT")" "$(jq .id "$RESULT")"

RESULT_VCS_EMAIL="$(jq .id "$RESULT")+$(jq -r .login "$RESULT")@users.noreply.github.com"

. ex/util/assert -eqv "$(jq -r .vcs_email "$ARTIFACT")" "$RESULT_VCS_EMAIL"

rm "$RESULT"

exit 0
