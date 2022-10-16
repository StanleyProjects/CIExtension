#!/bin/bash

SCRIPT='ex/github/tag/test.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

$SCRIPT ''; . ex/util/assert -eqv $? 101

$SCRIPT 'foo'; . ex/util/assert -eqv $? 122

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='kepocnhh'
export REPOSITORY_NAME='useless'
. ex/util/pipeline ex/github/assemble/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

QUERIES=(
 'unit/test/1' 'code/quality/1'
 'code/style/1' 'code/style/11'
 'unit_test' 'unit_test_2'
 'test/22' 'test/2222'
)
QUERIES_SIZE=${#QUERIES[@]}
for ((QUERY_INDEX=0; QUERY_INDEX<$QUERIES_SIZE; QUERY_INDEX++)); do
 TAG="${QUERIES[$QUERY_INDEX]}"
 echo "test tag [$((QUERY_INDEX + 1))/$QUERIES_SIZE] \"$TAG\"..."
 CODE=0
 CODE=$(curl -s -w %{http_code} -o /dev/null "$REPOSITORY_URL/git/refs/tags/$TAG")
 . ex/util/assert -eqv $CODE 200
 $SCRIPT "$TAG"; . ex/util/assert -eqv $? 41
done

echo "
Check success..."

QUERIES=('test/2' 'test/222')
for ((QUERY_INDEX=0; QUERY_INDEX<$QUERIES_SIZE; QUERY_INDEX++)); do
 TAG="${QUERIES[$QUERY_INDEX]}"
 echo "test tag [$((QUERY_INDEX + 1))/$QUERIES_SIZE] \"$TAG\"..."
 CODE=0
 CODE=$(curl -s -w %{http_code} -o /dev/null "$REPOSITORY_URL/git/refs/tags/$TAG")
 . ex/util/assert -eqv $CODE 200
 $SCRIPT "$TAG"; . ex/util/assert -eqv $? 0
done

QUERIES=('code' 'code/style' 'code/quality')
for ((QUERY_INDEX=0; QUERY_INDEX<$QUERIES_SIZE; QUERY_INDEX++)); do
 TAG="${QUERIES[$QUERY_INDEX]}"
 echo "test tag [$((QUERY_INDEX + 1))/$QUERIES_SIZE] \"$TAG\"..."
 CODE=0
 CODE=$(curl -s -w %{http_code} -o /dev/null "$REPOSITORY_URL/git/refs/tags/$TAG")
 . ex/util/assert -eqv $CODE 200
 $SCRIPT "$TAG"; . ex/util/assert -eqv $? 0
done

TAG="$(date +%s)"
CODE=0
CODE=$(curl -s -w %{http_code} -o /dev/null "$REPOSITORY_URL/git/refs/tags/$TAG")
. ex/util/assert -eqv $CODE 404

$SCRIPT "$TAG"; . ex/util/assert -eqv $? 0
