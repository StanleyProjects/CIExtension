#!/bin/bash

FILE='sample.json'

if [ ! -s "$FILE" ]; then
 echo "The file \"$FILE\" does not exist!"; exit 11
fi

SOURCE="$(cat "$FILE")"

if test -z "$SOURCE"; then
 echo "The source is empty!"; exit 12
fi

SOURCES=(
 '-f' "$FILE"
 '-j' "$SOURCE"
)
for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 2)); SOURCE_INDEX++)); do
 VAL_INT="$(date +%s)"
 VAL_STRING_EMPTY="$(date +%s)"
 VAL_STRING="$(date +%s)"
 VAL_BOOLEAN_TRUE="$(date +%s)"
 VAL_BOOLEAN_FALSE="$(date +%s)"
 . ex/util/json ${SOURCES[$((SOURCE_INDEX * 2 + 0))]} "${SOURCES[$((SOURCE_INDEX * 2 + 1))]}" \
  -si .val_int VAL_INT \
  -ss .val_string_empty VAL_STRING_EMPTY \
  -sfs .val_string VAL_STRING \
  -sb .val_boolean_true VAL_BOOLEAN_TRUE \
  -sb .val_boolean_false VAL_BOOLEAN_FALSE

 CHECKING=(
  'val_int' '42' "$VAL_INT"
  'val_string_empty' '' "$VAL_STRING_EMPTY"
  'val_string' 'foo' "$VAL_STRING"
  'val_boolean_true' 'true' "$VAL_BOOLEAN_TRUE"
  'val_boolean_false' 'false' "$VAL_BOOLEAN_FALSE"
 )
 for ((CHECKING_INDEX=0; CHECKING_INDEX<$((${#CHECKING[@]} / 3)); CHECKING_INDEX++)); do
  VALUE_NAME="${CHECKING[$((CHECKING_INDEX * 3 + 0))]}"
  EXPECTED="${CHECKING[$((CHECKING_INDEX * 3 + 1))]}"
  ACTUAL="${CHECKING[$((CHECKING_INDEX * 3 + 2))]}"
  if test "$ACTUAL" != "$EXPECTED"; then
   echo "Actual value of \"$VALUE_NAME\" is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((100 * SOURCE_INDEX + 20 + CHECKING_INDEX))
  fi
 done
done
