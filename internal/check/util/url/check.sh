#!/bin/bash

SCRIPT='ex/util/url'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=('1 2 3 4 5' '1 2 3 4 5 6 7'  '1 2 3 4 5 6 7 8 9')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 12
done

$SCRIPT -a 'foo' -a 'bar'; . ex/util/assert -eqv $? 41
$SCRIPT -h 'foo' -a 'bar'; . ex/util/assert -eqv $? 42
$SCRIPT -h 'foo' -h 'bar' -a 'baz'; . ex/util/assert -eqv $? 43

$SCRIPT -h 'foo' -h 'bar'; . ex/util/assert -eqv $? 21
$SCRIPT -h 'foo' -h 'bar' -h 'baz'; . ex/util/assert -eqv $? 21
$SCRIPT -u 'foo' -h 'bar'; . ex/util/assert -eqv $? 22
$SCRIPT -u 'foo' -h 'bar' -h 'baz'; . ex/util/assert -eqv $? 22

$SCRIPT -u 'foo' -u 'bar'; . ex/util/assert -eqv $? 52
$SCRIPT -u 'foo' -h 'bar' -u 'baz'; . ex/util/assert -eqv $? 53
$SCRIPT -u '' -a 'bar'; . ex/util/assert -eqv $? 61
$SCRIPT -h 'foo' -u ''; . ex/util/assert -eqv $? 62

$SCRIPT -o 'foo' -o 'bar'; . ex/util/assert -eqv $? 72
$SCRIPT -o 'foo' -h 'bar' -o 'baz'; . ex/util/assert -eqv $? 73
$SCRIPT -o '' -a 'bar'; . ex/util/assert -eqv $? 81
$SCRIPT -h 'foo' -o ''; . ex/util/assert -eqv $? 82
OUTPUT="/tmp/$(date +%s)"
touch "$OUTPUT"
. ex/util/assert -f "$OUTPUT"
$SCRIPT -o "$OUTPUT" -a 'bar'; . ex/util/assert -eqv $? 91
$SCRIPT -h 'foo' -o "$OUTPUT"; . ex/util/assert -eqv $? 92

$SCRIPT -e 1 -e 'bar'; . ex/util/assert -eqv $? 102
$SCRIPT -e 1 -h 'bar' -e 'baz'; . ex/util/assert -eqv $? 103
QUERIES=(
 '""' "''" '"foo"' 'true' 'false' '{}' '[]'
 '0' '-1' '-42' '1.2' '-3.4' '0.'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT -h 'foo' -e "${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 112
done

$SCRIPT -c 1 -c 'bar'; . ex/util/assert -eqv $? 122
$SCRIPT -c 1 -h 'bar' -c 'baz'; . ex/util/assert -eqv $? 123
QUERIES=(
 '""' "''" '"foo"' 'true' 'false' '{}' '[]'
 '0' '-1' '-42' '1.2' '-3.4' '0.'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT -h 'foo' -c "${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 132
done


$SCRIPT -m 1 -m 'bar'; . ex/util/assert -eqv $? 142
$SCRIPT -m 1 -h 'bar' -m 'baz'; . ex/util/assert -eqv $? 143
QUERIES=(
 '""' "''" '"foo"' 'true' 'false' '{}' '[]'
 '0' '-1' '-42' '1.2' '-3.4' '0.'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT -h 'foo' -m "${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 152
done

$SCRIPT -h '' -a 'bar'; . ex/util/assert -eqv $? 161
$SCRIPT -h 'foo' -h ''; . ex/util/assert -eqv $? 162

$SCRIPT -d 'foo' -d 'bar'; . ex/util/assert -eqv $? 172
$SCRIPT -d 'foo' -h 'bar' -d 'baz'; . ex/util/assert -eqv $? 173
$SCRIPT -d '' -a 'bar'; . ex/util/assert -eqv $? 181
$SCRIPT -h 'foo' -d ''; . ex/util/assert -eqv $? 182

$SCRIPT -u 'foo' -o 'bar'; . ex/util/assert -eqv $? 251

URL_TARGET="https://postman-echo.com/get"
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"

CODE_EXPECTED=201
[ $CODE_EXPECTED -eq 200 ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT -u "$URL_TARGET" -o "$OUTPUT" -e $CODE_EXPECTED; . ex/util/assert -eqv $? 252

echo "
Check success..."

rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT -u "$URL_TARGET" -o "$OUTPUT"; . ex/util/assert -eqv $? 0
. ex/util/assert -eqv 0 "$(jq -Mc '.args|length' "$OUTPUT")"
. ex/util/assert -eqv "$URL_TARGET" "$(jq -Mcer ".url|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT -u "$URL_TARGET" -o "$OUTPUT" -e 200; . ex/util/assert -eqv $? 0
. ex/util/assert -eqv 0 "$(jq -Mc '.args|length' "$OUTPUT")"
. ex/util/assert -eqv "$URL_TARGET" "$(jq -Mcer ".url|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"

echo "
args..."
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

/bin/bash -c "$SCRIPT -u \"$URL_TARGET\" -o \"$OUTPUT\" -e 200"; \
 . ex/util/assert -eqv $? 0

. ex/util/assert -s "$OUTPUT"
. ex/util/assert -eqv "$URL_TARGET" "$(jq -Mcer ".url|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
for ((URL_ARG_INDEX=0; URL_ARG_INDEX<$((${#URL_ARGS[@]} / 2)); URL_ARG_INDEX++)); do
 URL_ARG_KEY="${URL_ARGS[$((URL_ARG_INDEX * 2 + 0))]}"
 echo "check arg [$((URL_ARG_INDEX + 1))/$((${#URL_ARGS[@]} / 2))] \"$URL_ARG_KEY\"..."
 URL_ARG_VALUE="${URL_ARGS[$((URL_ARG_INDEX * 2 + 1))]}"
 . ex/util/assert -eqv "$URL_ARG_VALUE" "$(jq -Mcer ".args.$URL_ARG_KEY|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
done

echo "
headers..."
CHECK_HEADERS=(
 'h1' "$(date +%s)"
 'h2' "$(date +"%Y%m%d%H")"
 'h3' 'h3_value'
)
[ $((${#CHECK_HEADERS[@]} % 2)) -ne 0 ] && . ex/util/throw 101 "Illegal state!"
[ $((${#CHECK_HEADERS[@]} / 2)) -eq 0 ] && . ex/util/throw 101 "Illegal state!"
URL_POSTFIX=''
for ((URL_HEADER_INDEX=0; URL_HEADER_INDEX<$((${#CHECK_HEADERS[@]} / 2)); URL_HEADER_INDEX++)); do
 URL_HEADER_KEY="${CHECK_HEADERS[$((URL_HEADER_INDEX * 2 + 0))]}"
 URL_HEADER_VALUE="${CHECK_HEADERS[$((URL_HEADER_INDEX * 2 + 1))]}"
 URL_POSTFIX="$URL_POSTFIX -h \"${URL_HEADER_KEY}: $URL_HEADER_VALUE\""
done

URL_TARGET="https://postman-echo.com/headers"

rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
/bin/bash -c "$SCRIPT -u \"$URL_TARGET\" -o \"$OUTPUT\" $URL_POSTFIX -e 200"; \
 . ex/util/assert -eqv $? 0

. ex/util/assert -s "$OUTPUT"
for ((URL_HEADER_INDEX=0; URL_HEADER_INDEX<$((${#CHECK_HEADERS[@]} / 2)); URL_HEADER_INDEX++)); do
 URL_HEADER_KEY="${CHECK_HEADERS[$((URL_HEADER_INDEX * 2 + 0))]}"
 echo "check header [$((URL_HEADER_INDEX + 1))/$((${#CHECK_HEADERS[@]} / 2))] \"$URL_HEADER_KEY\"..."
 URL_HEADER_VALUE="${CHECK_HEADERS[$((URL_HEADER_INDEX * 2 + 1))]}"
 . ex/util/assert -eqv "$URL_HEADER_VALUE" "$(jq -Mcer ".headers.$URL_HEADER_KEY|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"
done

echo "
data..."
URL_TARGET="https://postman-echo.com/post"
URL_DATA_EXPECTED="data $(date +%s)"
URL_POSTFIX='-h "Content-Type: text/plain"'

rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
/bin/bash -c "$SCRIPT -u \"$URL_TARGET\" -o \"$OUTPUT\" -d '$URL_DATA_EXPECTED' $URL_POSTFIX -e 404"; \
 . ex/util/assert -eqv $? 0
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
/bin/bash -c "$SCRIPT -u \"$URL_TARGET\" -o \"$OUTPUT\" -d '$URL_DATA_EXPECTED' $URL_POSTFIX -x GET -e 404"; \
 . ex/util/assert -eqv $? 0
rm "$OUTPUT"
[ -f "$OUTPUT" ] && . ex/util/throw 101 "Illegal state!"
/bin/bash -c "$SCRIPT -u \"$URL_TARGET\" -o \"$OUTPUT\" -d '$URL_DATA_EXPECTED' $URL_POSTFIX -x POST -e 200"; \
 . ex/util/assert -eqv $? 0

. ex/util/assert -s "$OUTPUT"
. ex/util/assert -eqv "$URL_DATA_EXPECTED" "$(jq -Mcer ".data|select((.!=null)and(type==\"string\")and(.!=\"\"))" "$OUTPUT")"

exit 0
