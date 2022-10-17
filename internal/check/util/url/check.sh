#!/bin/bash

SCRIPT='ex/util/url'
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
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"

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
$SCRIPT "$URL_TARGET" "$OUTPUT"; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$OUTPUT"

. ex/util/assert -eqv "$URL_TARGET" "$(jq -Mcer ".url|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
for ((URL_ARG_INDEX=0; URL_ARG_INDEX<$((${#URL_ARGS[@]} / 2)); URL_ARG_INDEX++)); do
 URL_ARG_KEY="${URL_ARGS[$((URL_ARG_INDEX * 2 + 0))]}"
 URL_ARG_VALUE="${URL_ARGS[$((URL_ARG_INDEX * 2 + 1))]}"
 . ex/util/assert -eqv "$URL_ARG_VALUE" "$(jq -Mcer ".args.$URL_ARG_KEY|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
done
