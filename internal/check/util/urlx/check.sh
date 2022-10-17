#!/bin/bash

SCRIPT='ex/util/urlx'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=('""' "''")
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT ${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 12
done

CHECK_ENVIRONMENT='foo'
$SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 21
CHECK_ENVIRONMENT='{}'
$SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 21
QUERIES=('""' '1' 'true' 'false' '{}' '[]' 'null')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".url=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 21
done
. ex/util/json_merge -v CHECK_ENVIRONMENT '.url="foo"'

for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".output=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 31
done
OUTPUT="/tmp/$(date +%s)"
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
. ex/util/json_merge -v CHECK_ENVIRONMENT ".output=\"$OUTPUT\""

QUERIES=('""' '"foo"' 'true' 'false' '{}' '[]')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".timeout.connect=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 112
done
QUERIES=('0' '-1' '-42' '1.2' '-3.4' '0.')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".timeout.connect=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 114
done
. ex/util/json_merge -v CHECK_ENVIRONMENT '.timeout.connect=4'

QUERIES=('""' '"foo"' 'true' 'false' '{}' '[]')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".timeout.max=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 122
done
QUERIES=('0' '-1' '-42' '1.2' '-3.4' '0.')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".timeout.max=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 124
done
. ex/util/json_merge -v CHECK_ENVIRONMENT '.timeout.max=16'

QUERIES=('""' '"foo"' 'true' 'false' '{}' '[]')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".code.expected=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 132
done
QUERIES=('0' '-1' '-42' '1.2' '-3.4' '0.')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".code.expected=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 134
done
. ex/util/json_merge -v CHECK_ENVIRONMENT '.code.expected=200'

QUERIES=('""' '"foo"' '1' 'true' 'false' '[]')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".headers=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 41
done

QUERIES=('""' '1' 'true' 'false' '{}' '[]' 'null')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_ENVIRONMENT \
  '.headers={}' \
  ".headers.a=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 131
 . ex/util/json_merge -v CHECK_ENVIRONMENT \
  '.headers.a="1"' \
  ".headers.b=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 132
 . ex/util/json_merge -v CHECK_ENVIRONMENT \
  '.headers.b="2"' \
  ".headers.c=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 133
done
. ex/util/json_merge -v CHECK_ENVIRONMENT '.headers.c="3"'

$SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 91

echo "
Check success..."

URL_TARGET="https://postman-echo.com/get"
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
. ex/util/json_merge -v CHECK_ENVIRONMENT \
 ".url=\"$URL_TARGET\"" \
 ".output=\"$OUTPUT\""

$SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$OUTPUT"
. ex/util/assert -eqv "$URL_TARGET" "$(jq -Mcer ".url|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"

URL_TARGET="https://postman-echo.com/get"

URL_ARGS=(
 'foo' "$(date +%s)"
 'bar' "$(date +"%Y%m%d%H")"
 'baz' 'baz_value'
)
[ $((${#URL_ARGS[@]} % 2)) -ne 0 ] && . ex/util/throw 101 "Illegal state!"
[ $((${#URL_ARGS[@]} / 2)) -eq 0 ] && . ex/util/throw 101 "Illegal state!"
URL_TARGET="https://postman-echo.com/get"
URL_ARG_KEY="${URL_ARGS[$((URL_ARG_INDEX * 2 + 0))]}"
URL_ARG_VALUE="${URL_ARGS[$((URL_ARG_INDEX * 2 + 1))]}"
URL_TARGET="${URL_TARGET}?${URL_ARG_KEY}=${URL_ARG_VALUE}"
for ((URL_ARG_INDEX=1; URL_ARG_INDEX<$((${#URL_ARGS[@]} / 2)); URL_ARG_INDEX++)); do
 URL_ARG_KEY="${URL_ARGS[$((URL_ARG_INDEX * 2 + 0))]}"
 URL_ARG_VALUE="${URL_ARGS[$((URL_ARG_INDEX * 2 + 1))]}"
 URL_TARGET="${URL_TARGET}&${URL_ARG_KEY}=${URL_ARG_VALUE}"
done
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
. ex/util/json_merge -v CHECK_ENVIRONMENT \
 ".url=\"$URL_TARGET\"" \
 ".output=\"$OUTPUT\""

URL_HEADERS=(
 'h1' "$(date +%s)"
 'h2' "$(date +"%Y%m%d%H")"
 'h3' 'h3_value'
)
[ $((${#URL_HEADERS[@]} % 2)) -ne 0 ] && . ex/util/throw 101 "Illegal state!"
[ $((${#URL_HEADERS[@]} / 2)) -eq 0 ] && . ex/util/throw 101 "Illegal state!"
for ((URL_HEADER_INDEX=0; URL_HEADER_INDEX<$((${#URL_HEADERS[@]} / 2)); URL_HEADER_INDEX++)); do
 URL_HEADER_KEY="${URL_HEADERS[$((URL_HEADER_INDEX * 2 + 0))]}"
 URL_HEADER_VALUE="${URL_HEADERS[$((URL_HEADER_INDEX * 2 + 1))]}"
 . ex/util/json_merge -v CHECK_ENVIRONMENT ".headers.${URL_HEADER_KEY}=\"$URL_HEADER_VALUE\""
done

$SCRIPT "$CHECK_ENVIRONMENT"; . ex/util/assert -eqv $? 0

. ex/util/assert -s "$OUTPUT"
. ex/util/assert -eqv "$URL_TARGET" "$(jq -Mcer ".url|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
for ((URL_ARG_INDEX=0; URL_ARG_INDEX<$((${#URL_ARGS[@]} / 2)); URL_ARG_INDEX++)); do
 URL_ARG_KEY="${URL_ARGS[$((URL_ARG_INDEX * 2 + 0))]}"
 URL_ARG_VALUE="${URL_ARGS[$((URL_ARG_INDEX * 2 + 1))]}"
 . ex/util/assert -eqv "$URL_ARG_VALUE" "$(jq -Mcer ".args.$URL_ARG_KEY|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
done
for ((URL_HEADER_INDEX=0; URL_HEADER_INDEX<$((${#URL_HEADERS[@]} / 2)); URL_HEADER_INDEX++)); do
 URL_HEADER_KEY="${URL_HEADERS[$((URL_HEADER_INDEX * 2 + 0))]}"
 URL_HEADER_VALUE="${URL_HEADERS[$((URL_HEADER_INDEX * 2 + 1))]}"
 . ex/util/assert -eqv "$URL_HEADER_VALUE" "$(jq -Mcer ".headers.$URL_HEADER_KEY|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
done
