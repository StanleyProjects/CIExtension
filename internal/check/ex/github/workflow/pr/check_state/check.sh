#!/bin/bash

SCRIPT='ex/github/workflow/pr/check_state.sh'
. ex/util/assert -s "$SCRIPT"

echo '
Check error...'

$SCRIPT; . ex/util/assert -eqv $? 11
[ ! -z "$PR_NUMBER" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 101
export PR_NUMBER='foo'
[ -f assemble/vcs/repository.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT 1; . ex/util/assert -eqv $? 102
. ex/util/mkdirs assemble/vcs
touch assemble/vcs/repository.json
$SCRIPT 1; . ex/util/assert -eqv $? 102
echo 'foo' > assemble/vcs/repository.json
$SCRIPT 1; . ex/util/assert -eqv $? 102
echo '{}' > assemble/vcs/repository.json
$SCRIPT 1; . ex/util/assert -eqv $? 102
. ex/util/json_merge -f assemble/vcs/repository.json \
 '.url="bar"'
$SCRIPT 1; . ex/util/assert -eqv $? 12

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
REPOSITORY_URL="$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME"
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$REPOSITORY_URL\""
rm "$ARTIFACT"
PR_NUMBER=15

$SCRIPT 'baz'; . ex/util/assert -eqv $? 102

echo '
Check success...'

$SCRIPT 'closed'; . ex/util/assert -eqv $? 0

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
. ex/util/assert -s "$ARTIFACT"
. ex/util/json -f "$ARTIFACT" -sfs ".url" ACTUAL_VALUE
. ex/util/assert -eqv "$ACTUAL_VALUE" "$REPOSITORY_URL/pulls/$PR_NUMBER"
. ex/util/json -f "$ARTIFACT" -si ".number" ACTUAL_VALUE
. ex/util/assert -eq ACTUAL_VALUE PR_NUMBER

exit 0
