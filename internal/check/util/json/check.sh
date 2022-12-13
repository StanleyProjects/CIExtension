#!/bin/bash

SCRIPT='ex/util/json'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

SOURCE='{
  "val_int": 42,
  "val_float": 2.3,
  "val_boolean_true": true,
  "val_boolean_false": false,
  "val_string": "foo",
  "val_string_empty": "",
  "val_object": {
    "v1": 1,
    "v2": 2
  },
  "val_array_2": ["bar", "baz"],
  "val_array_empty": [],
  "val_null": null
}'

. ex/util/require SOURCE

FILE='sample.json'
echo "$SOURCE" > "$FILE"

. ex/util/assert -s "$FILE"

rm "${FILE}.empty"
touch "${FILE}.empty"

. ex/util/assert -f "${FILE}.empty"
[ -s "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ -f "${FILE}.not" ] && . ex/util/throw 101 "Illegal state!"

echo "
Check arguments..."

QUERIES=(
 ''
 '1'
 '1 2'
 '1 2 3'
 '1 2 3 4'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=(
 '1'
 '1 2'
 '1 2 3 1'
 '1 2 3 1 2'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT o s 1 2 3 ${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 12
done

echo "
Check source options..."

QUERIES=('' 'a' '-a' 'foo' '1')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT '${QUERIES[$QUERY_INDEX]}' s 1 2 3"; . ex/util/assert -eqv $? 13
done

echo "
Check sources..."

$SCRIPT -j '' 1 2 3; . ex/util/assert -eqv $? 121
$SCRIPT -f "${FILE}.not" 1 2 3; . ex/util/assert -eqv $? 122
$SCRIPT -f "${FILE}.empty" 1 2 3; . ex/util/assert -eqv $? 123

SOURCE_BASE64="$(echo "$SOURCE" | base64)"

SOURCES=(
 '-j' "$SOURCE" 41
 '-f' "$FILE" 42
 '--base64' "$SOURCE_BASE64" 43
)
for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 3)); SOURCE_INDEX++)); do
 SOURCE_OPTION="${SOURCES[$((SOURCE_INDEX * 3 + 0))]}"
 ACTUAL_SOURCE="${SOURCES[$((SOURCE_INDEX * 3 + 1))]}"
 EXPECTED=${SOURCES[$((SOURCE_INDEX * 3 + 2))]}
 echo "Source option: $SOURCE_OPTION"
 echo "
 Check query options..."

 QUERIES=('a' '-a' 'foo' '1')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" ${QUERIES[$QUERY_INDEX]} 2 3; . ex/util/assert -eqv $? 21
 done

 echo "
 Check queries..."

 QUERIES=('-si a' '-sfs -a' '-sb foo')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" ${QUERIES[$QUERY_INDEX]} 3; . ex/util/assert -eqv $? $EXPECTED
 done

 QUERY_OPTION='-si'
 echo "query option: \"${QUERY_OPTION}\"..."
 QUERIES=(
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_string'
  '.val_string_empty'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" "$QUERY_OPTION" "${QUERIES[$QUERY_INDEX]}" 3; . ex/util/assert -eqv $? $EXPECTED
 done

 QUERY_OPTION='-sfs'
 echo "query option: \"${QUERY_OPTION}\"..."
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_string_empty'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" "$QUERY_OPTION" "${QUERIES[$QUERY_INDEX]}" 3; . ex/util/assert -eqv $? $EXPECTED
 done

 QUERY_OPTION='-ss'
 echo "query option: \"${QUERY_OPTION}\"..."
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" "$QUERY_OPTION" "${QUERIES[$QUERY_INDEX]}" 3; . ex/util/assert -eqv $? $EXPECTED
 done

 QUERY_OPTION='-sb'
 echo "query option: \"${QUERY_OPTION}\"..."
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_string'
  '.val_string_empty'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" "$QUERY_OPTION" "${QUERIES[$QUERY_INDEX]}" 3; . ex/util/assert -eqv $? $EXPECTED
 done

 QUERY_OPTION='-sa'
 echo "query option: \"${QUERY_OPTION}\"..."
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_string'
  '.val_string_empty'
  '.val_object'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" "$QUERY_OPTION" "${QUERIES[$QUERY_INDEX]}" 3; . ex/util/assert -eqv $? $EXPECTED
 done

 QUERY_OPTION='-sfa'
 echo "query option: \"${QUERY_OPTION}\"..."
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_string'
  '.val_string_empty'
  '.val_object'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" "$QUERY_OPTION" "${QUERIES[$QUERY_INDEX]}" 3; . ex/util/assert -eqv $? $EXPECTED
 done

 echo "
 Check query errors..."

 QUERIES=('' '-si .val_int VAL_INT')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" ${QUERIES[$QUERY_INDEX]} '' 2 3; . ex/util/assert -eqv $? 101
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" ${QUERIES[$QUERY_INDEX]} -si '' 3; . ex/util/assert -eqv $? 102
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" ${QUERIES[$QUERY_INDEX]} -si 2 ''; . ex/util/assert -eqv $? 103
 done

 QUERIES=('1' '2' '42' '-a' '/foo')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  $SCRIPT "$SOURCE_OPTION" "$ACTUAL_SOURCE" -si .val_int "${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 104
 done
done

echo "
Check success..."

SOURCES=(
 '-f' "$FILE"
 '-j' "$SOURCE"
 '--base64' "$SOURCE_BASE64"
)
for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 2)); SOURCE_INDEX++)); do
 SOURCE_OPTION="${SOURCES[$((SOURCE_INDEX * 2 + 0))]}"
 echo "Source option: $SOURCE_OPTION"

 VAL_INT="VAL_INT$(date +%s)"
 VAL_STRING_EMPTY="VAL_STRING_EMPTY$(date +%s)"
 VAL_STRING="VAL_STRING$(date +%s)"
 VAL_BOOLEAN_TRUE="VAL_BOOLEAN_TRUE$(date +%s)"
 VAL_BOOLEAN_FALSE="VAL_BOOLEAN_FALSE$(date +%s)"
 VAL_ARRAY_2="VAL_ARRAY_2$(date +%s)"
 VAL_ARRAY_EMPTY="VAL_ARRAY_EMPTY$(date +%s)"
 . $SCRIPT "$SOURCE_OPTION" "${SOURCES[$((SOURCE_INDEX * 2 + 1))]}" \
  -si .val_int VAL_INT \
  -ss .val_string_empty VAL_STRING_EMPTY \
  -sfs .val_string VAL_STRING \
  -sb .val_boolean_true VAL_BOOLEAN_TRUE \
  -sb .val_boolean_false VAL_BOOLEAN_FALSE \
  -sfa .val_array_2 VAL_ARRAY_2 \
  -sa .val_array_empty VAL_ARRAY_EMPTY

 CHECKING=(
  'val_int' '42' "$VAL_INT"
  'val_string_empty' '' "$VAL_STRING_EMPTY"
  'val_string' 'foo' "$VAL_STRING"
  'val_boolean_true' 'true' "$VAL_BOOLEAN_TRUE"
  'val_boolean_false' 'false' "$VAL_BOOLEAN_FALSE"
  'val_array_2' '["bar","baz"]' "$VAL_ARRAY_2"
  'val_array_empty' '[]' "$VAL_ARRAY_EMPTY"
 )
 for ((CHECKING_INDEX=0; CHECKING_INDEX<$((${#CHECKING[@]} / 3)); CHECKING_INDEX++)); do
  VALUE_NAME="${CHECKING[$((CHECKING_INDEX * 3 + 0))]}"
  EXPECTED="${CHECKING[$((CHECKING_INDEX * 3 + 1))]}"
  ACTUAL="${CHECKING[$((CHECKING_INDEX * 3 + 2))]}"
  . ex/util/assert -eq ACTUAL EXPECTED
 done
done

exit 0
