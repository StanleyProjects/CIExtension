#!/bin/bash

SCRIPT='ex/github/assemble/pr.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 101

export PR_NUMBER='foo'

$SCRIPT; . ex/util/assert -eqv $? 122

[ -f assemble/vcs/repository.json ] && . ex/util/throw 101 "Illegal state!"
. ex/util/mkdirs assemble/vcs
touch assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 123

echo 'foo' > assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 42
echo '{}' > assemble/vcs/repository.json
$SCRIPT; . ex/util/assert -eqv $? 42

. ex/util/json_merge -f assemble/vcs/repository.json \
 '.url="foo"'
$SCRIPT; . ex/util/assert -eqv $? 21

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='kepocnhh'
REPOSITORY_NAME='useless'
REPOSITORY_URL="$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME"

. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$REPOSITORY_URL\""
$SCRIPT; . ex/util/assert -eqv $? 21

echo "
Check success..."

PR_NUMBER=45
$SCRIPT; . ex/util/assert -eqv $? 0
ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
. ex/util/assert -s "$ARTIFACT"

EXPECTED_ARTIFACT="/tmp/$(date +%s)"
[ -f "$EXPECTED_ARTIFACT" ] && . ex/util/throw 101 "Illegal state!"
curl -f -o "$EXPECTED_ARTIFACT" "$REPOSITORY_URL/pulls/$PR_NUMBER" \
 || . ex/util/throw 101 "Illegal state!"

QUERIES=('.url' '.title' '.head.sha' '.base.sha' '.merged_by.login')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  QUERY="${QUERIES[$QUERY_INDEX]}"
  . ex/util/json -f "$ARTIFACT" -sfs "$QUERY" ACTUAL_VALUE
  . ex/util/json -f "$EXPECTED_ARTIFACT" -sfs "$QUERY" EXPECTED_VALUE
  . ex/util/assert -eq ACTUAL_VALUE EXPECTED_VALUE
done

QUERIES=('.id' '.number')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  QUERY="${QUERIES[$QUERY_INDEX]}"
  . ex/util/json -f "$ARTIFACT" -si "$QUERY" ACTUAL_VALUE
  . ex/util/json -f "$EXPECTED_ARTIFACT" -si "$QUERY" EXPECTED_VALUE
  . ex/util/assert -eq ACTUAL_VALUE EXPECTED_VALUE
done

. ex/util/json -f "$ARTIFACT" -sfs ".head.repo.name" ACTUAL_VALUE
. ex/util/json -f "$EXPECTED_ARTIFACT" -sfs ".head.repo.name" EXPECTED_VALUE
. ex/util/assert -eq ACTUAL_VALUE EXPECTED_VALUE
. ex/util/assert -eq ACTUAL_VALUE REPOSITORY_NAME

. ex/util/json -f "$ARTIFACT" -sfs ".head.repo.owner.login" ACTUAL_VALUE
. ex/util/json -f "$EXPECTED_ARTIFACT" -sfs ".head.repo.owner.login" EXPECTED_VALUE
. ex/util/assert -eq ACTUAL_VALUE EXPECTED_VALUE
. ex/util/assert -eq ACTUAL_VALUE REPOSITORY_OWNER

exit 0
