#!/bin/bash

SCRIPT='ex/github/release.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

$SCRIPT ''; . ex/util/assert -eqv $? 101

CHECK_BODY='{}'
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 41
QUERIES=('false' 'true' '42' '[]' '{}' '""')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_BODY ".name=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 41
done

CHECK_RELEASE_NAME="release $(date +%s)"
. ex/util/json_merge -v CHECK_BODY ".name=\"$CHECK_RELEASE_NAME\""
[ -f assemble/vcs/repository.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 122

[ -d assemble/vcs ] && . ex/util/throw 101 "Illegal state!"
. ex/util/mkdirs assemble/vcs
echo '{}' > assemble/vcs/repository.json
VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='kepocnhh'
REPOSITORY_NAME='useless'
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME\""
 . ex/util/assert -s assemble/vcs/repository.json
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 3

echo "Not implemented!"; exit 1 # todo

echo "
Check success..."

echo "Not implemented!"; exit 1 # todo

exit 0
