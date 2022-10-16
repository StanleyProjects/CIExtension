#!/bin/bash

SCRIPT='ex/util/json_merge'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1' '1 2')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=('' 'a' '-a' 'foo' '1')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT "${QUERIES[$QUERY_INDEX]}" 2 3; . ex/util/assert -eqv $? 13
done

$SCRIPT -v '' 3; . ex/util/assert -eqv $? 121

FILE="/tmp/$(date +%s)"
echo "{}" > "$FILE"

rm "${FILE}.empty"
touch "${FILE}.empty"

if [ ! -f "${FILE}.empty" ]; then
 echo "The file \"${FILE}.empty\" does not exist!"; exit 16
elif test -s "${FILE}.empty"; then
 echo "The file \"${FILE}.empty\" does not empty!"; exit 17
fi

if test -s "${FILE}.not"; then
 echo "The file \"${FILE}.not\" exists!"; exit 19
fi

$SCRIPT -f "${FILE}.not" 3; . ex/util/assert -eqv $? 122
$SCRIPT -f "${FILE}.empty" 3; . ex/util/assert -eqv $? 123

CHECK_VARIABLE='{}'

SOURCES=(
 '-f' "$FILE"
 '-v' "CHECK_VARIABLE"
)
for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 2)); SOURCE_INDEX++)); do
 SOURCE_OPTION="${SOURCES[$((SOURCE_INDEX * 2 + 0))]}"
 SOURCE="${SOURCES[$((SOURCE_INDEX * 2 + 1))]}"
 echo "check [$((SOURCE_INDEX + 1))/$((${#SOURCES[@]} / 2))], option: $SOURCE_OPTION"

 QUERIES=('a' '-' 'foo' '/')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  echo "check [$((QUERY_INDEX + 1))/$((SOURCE_INDEX + 1))/$((${#SOURCES[@]} / 2))]..."
  case "$SOURCE_OPTION" in
   '-v') EXPECTED=141;;
   '-f') EXPECTED=151;;
   *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
  esac
  $SCRIPT "$SOURCE_OPTION" "$SOURCE" ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? $EXPECTED
 done
done

echo "
Check success..."

SOURCES=(
 '-f' "$FILE"
 '-v' "CHECK_VARIABLE"
)
for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 2)); SOURCE_INDEX++)); do
 SOURCE_OPTION="${SOURCES[$((SOURCE_INDEX * 2 + 0))]}"
 SOURCE="${SOURCES[$((SOURCE_INDEX * 2 + 1))]}"
 echo "check [$((SOURCE_INDEX + 1))/$((${#SOURCES[@]} / 2))], option: $SOURCE_OPTION"

 KEY='foo'
 EXPECTED_VALUE='null'
 case "$SOURCE_OPTION" in
  '-v') ACTUAL_VALUE="$(echo "${!SOURCE}" | jq -Mce ".$KEY")";;
  '-f') ACTUAL_VALUE="$(jq -Mce ".$KEY" "$SOURCE")";;
  *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
 esac
 . ex/util/assert -eq EXPECTED_VALUE ACTUAL_VALUE
 EXPECTED_VALUE=1
 . $SCRIPT "$SOURCE_OPTION" "$SOURCE" ".$KEY=$EXPECTED_VALUE"
 case "$SOURCE_OPTION" in
  '-v') ACTUAL_VALUE="$(echo "${!SOURCE}" | jq -Mce ".$KEY")";;
  '-f') ACTUAL_VALUE="$(jq -Mce ".$KEY" "$SOURCE")";;
  *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
 esac
 . ex/util/assert -eq EXPECTED_VALUE ACTUAL_VALUE
 EXPECTED_VALUE='bar'
 . $SCRIPT "$SOURCE_OPTION" "$SOURCE" ".$KEY=\"$EXPECTED_VALUE\""
 case "$SOURCE_OPTION" in
  '-v') ACTUAL_VALUE="$(echo "${!SOURCE}" | jq -Mcer ".$KEY")";;
  '-f') ACTUAL_VALUE="$(jq -Mcer ".$KEY" "$SOURCE")";;
  *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
 esac
 . ex/util/assert -eq EXPECTED_VALUE ACTUAL_VALUE
done

echo "final check..."

FILE="/tmp/$(date +%s)"
echo "{}" > "$FILE"

RAWS=(
 'valInt' '1'
 'valBoolean' 'true'
 'valBooleanFalse' 'false'
 'valNull' 'null'
)
for ((QUERY_INDEX=0; QUERY_INDEX<$((${#RAWS[@]} / 2)); QUERY_INDEX++)); do
 . ex/util/assert -eqv 'null' "$(jq -Mce ".${RAWS[$((QUERY_INDEX * 2))]}" "$FILE")"
done
STRINGS=(
 'valString' '42'
 'valStringEmpty' ''
)
for ((QUERY_INDEX=0; QUERY_INDEX<$((${#STRINGS[@]} / 2)); QUERY_INDEX++)); do
 . ex/util/assert -eqv 'null' "$(jq -Mce ".${STRINGS[$((QUERY_INDEX * 2))]}" "$FILE")"
done

. $SCRIPT -f "$FILE" \
 ".valInt=1" \
 ".valString=\"42\"" \
 ".valStringEmpty=\"\"" \
 ".valBoolean=true" \
 ".valBooleanFalse=false" \
 ".valNull=null"

for ((QUERY_INDEX=0; QUERY_INDEX<$((${#RAWS[@]} / 2)); QUERY_INDEX++)); do
 KEY_INDEX=$((QUERY_INDEX * 2))
 VALUE_INDEX=$((QUERY_INDEX * 2 + 1))
 . ex/util/assert -eqv "${RAWS[$VALUE_INDEX]}" "$(jq -Mce ".${RAWS[$KEY_INDEX]}" "$FILE")"
done

for ((QUERY_INDEX=0; QUERY_INDEX<$((${#STRINGS[@]} / 2)); QUERY_INDEX++)); do
 KEY_INDEX=$((QUERY_INDEX * 2))
 VALUE_INDEX=$((QUERY_INDEX * 2 + 1))
 . ex/util/assert -eqv "${STRINGS[$VALUE_INDEX]}" "$(jq -Mcer ".${STRINGS[$KEY_INDEX]}" "$FILE")"
done
