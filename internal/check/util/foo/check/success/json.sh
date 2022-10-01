#!/bin/bash

FILE='sample.json'

if [ ! -s "$FILE" ]; then
 echo "The file \"$FILE\" does not exist!"; exit 11
fi

. ex/util/json -j "$(cat "$FILE")" \
 -si .val_int VAL_INT \
 -sfs .val_string VAL_STRING \
 -sb .val_boolean_true VAL_BOOLEAN_TRUE \
 -sb .val_boolean_false VAL_BOOLEAN_FALSE

ARRAY=(
 'val_int' '42' "$VAL_INT"
 'val_string' 'foo' "$VAL_STRING"
 'val_boolean_true' 'true' "$VAL_BOOLEAN_TRUE"
 'val_boolean_false' 'false' "$VAL_BOOLEAN_FALSE"
)
for ((i=0; i<$((${#ARRAY[@]} / 3)); i++)); do
 VALUE_NAME="${ARRAY[$((i * 3 + 0))]}"
 EXPECTED="${ARRAY[$((i * 3 + 1))]}"
 ACTUAL="${ARRAY[$((i * 3 + 2))]}"
 if test "$ACTUAL" != "$EXPECTED"; then
  echo "Actual value of \"$VALUE_NAME\" is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20+i))
 fi
done
