#!/bin/bash

SCRIPT='ex/util/urlx'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=('"" ""' '"" 2' '1 ""')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT ${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 12
done

OUTPUT="/tmp/$(date +%s)"
touch "$OUTPUT"
. ex/util/assert -f "$OUTPUT"
$SCRIPT 1 "$OUTPUT"; . ex/util/assert -eqv $? 21
rm "$OUTPUT"
$SCRIPT 1 2; . ex/util/assert -eqv $? 22

echo "
Check success..."

OUTPUT="/tmp/$(date +%s)"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"

VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
$SCRIPT "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME" "$OUTPUT"; . ex/util/assert -eqv $? 0

. ex/util/assert -s "$OUTPUT"
. ex/util/assert -eqv "$(jq -r .name "$OUTPUT")" "$REPOSITORY_NAME"
. ex/util/assert -eqv "$(jq -r .owner.login "$OUTPUT")" "$REPOSITORY_OWNER"

rm "$OUTPUT"
$SCRIPT "https://postman-echo.com/get?foo=1" "$OUTPUT"; . ex/util/assert -eqv $? 0
jq . "$OUTPUT"

exit 1 # todo
