#!/bin/bash

echo "
Check error..."

EXPECTED=101
ACTUAL=0
ex/github/assemble/worker.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi

export VCS_DOMAIN='https://api.github.com'

EXPECTED=102
ACTUAL=0
ex/github/assemble/worker.sh; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 102
fi

echo "
Check success..."

VCS_PAT="$GITHUB_PAT"
mkdir -p assemble/vcs
. ex/github/assemble/worker.sh

RESULT="/tmp/$(date +%s)"
if test -f "$RESULT"; then
 echo "File exists!"
 exit 111
fi
curl -f -w %{http_code} -o "$RESULT" "$VCS_DOMAIN/user" \
 -H "Authorization: token $GITHUB_PAT" || exit 112

ARTIFACT='assemble/vcs/worker.json'
if [ ! -s "$ARTIFACT" ]; then
 echo "File does not exist!"
 exit 21
fi

if test "$(jq -r .login "$ARTIFACT")" != "$(jq -r .login "$RESULT")"; then
 echo "Actual user login error!"
 exit 31
fi

if test "$(jq .id "$ARTIFACT")" != "$(jq .id "$RESULT")"; then
 echo "Actual user id error!"
 exit 32
fi

RESULT_VCS_EMAIL="$(jq .id "$RESULT")+$(jq -r .login "$RESULT")@users.noreply.github.com"

if test "$(jq -r .vcs_email "$ARTIFACT")" != "$RESULT_VCS_EMAIL"; then
 echo "Actual user VCS email error!"
 exit 33
fi

rm "$RESULT"

exit 0
