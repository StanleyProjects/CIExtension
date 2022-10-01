#!/bin/bash

FILE='sample.json'

if [ ! -s "$FILE" ]; then
 echo "The file \"$FILE\" does not exist!"; exit 11
fi

SOURCE="$(cat "$FILE")"

if test -z "$SOURCE"; then
 echo "The source is empty!"; exit 12
fi

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

echo "
Check arguments..."

EXPECTED=11
ARRAY=(
 ''
 '1'
 '1 2'
 '1 2 3'
 '1 2 3 4'
)
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json ${ARRAY[$i]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20+i))
 fi
done

EXPECTED=12
ARRAY=(
 '1'
 '1 2'
 '1 2 3 1'
 '1 2 3 1 2'
)
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json o s 1 2 3 ${ARRAY[$i]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((30+i))
 fi
done

echo "
Check source options..."

EXPECTED=13
ARRAY=('' 'a' '-a' 'foo' '1')
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json "${ARRAY[$i]}" s 1 2 3; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((40+i))
 fi
done

echo "
Check sources..."

EXPECTED=121
ACTUAL=0
ex/util/json -j '' 1 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 51
fi

EXPECTED=122
ACTUAL=0
ex/util/json -f "${FILE}.not" 1 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 52
fi

EXPECTED=123
ACTUAL=0
ex/util/json -f "${FILE}.empty" 1 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 53
fi

echo "
Check query options..."

EXPECTED=101
ACTUAL=0
ex/util/json -f "$FILE" '' 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 161
fi
ACTUAL=0
ex/util/json -j "$SOURCE" '' 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 261
fi

EXPECTED=21
ARRAY=('a' '-a' 'foo' '1')
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json -f "$FILE" "${ARRAY[$i]}" 2 3; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((170+i))
 fi
 ACTUAL=0
 ex/util/json -j "$SOURCE" "${ARRAY[$i]}" 2 3; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((270+i))
 fi
done

echo "
Check queries..."

ARRAY=('a' '-a' 'foo'
 '.val_boolean_true'
 '.val_boolean_false'
 '.val_string'
 '.val_string_empty'
 '.val_object'
 '.val_array_2'
 '.val_array_empty'
 '.val_null')
for ((i=0; i<${#ARRAY[@]}; i++)); do
 EXPECTED=42
 ACTUAL=0
 ex/util/json -f "$FILE" -si "${ARRAY[$i]}" 3; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((180+i))
 fi
 EXPECTED=41
 ACTUAL=0
 ex/util/json -j "$SOURCE" -si "${ARRAY[$i]}" 3; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((280+i))
 fi
done

echo "
Check query errors..."

ARRAY=('' '-si .val_int VAL_INT')
for ((i=0; i<${#ARRAY[@]}; i++)); do
 SOURCES=(
  '-f' "$FILE"
  '-j' "$SOURCE"
 )
 for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 2)); SOURCE_INDEX++)); do
  EXPECTED=101
  ACTUAL=0
  ex/util/json ${SOURCES[$((j * 2 + 0))]} "${SOURCES[$((j * 2 + 1))]}" ${ARRAY[$i]} '' 2 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * j + 610 + i))
  fi
  EXPECTED=102
  ACTUAL=0
  ex/util/json ${SOURCES[$((j * 2 + 0))]} "${SOURCES[$((j * 2 + 1))]}" ${ARRAY[$i]} -si '' 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * j + 620 + i))
  fi
  EXPECTED=103
  ACTUAL=0
  ex/util/json ${SOURCES[$((j * 2 + 0))]} "${SOURCES[$((j * 2 + 1))]}" ${ARRAY[$i]} -si 2 ''; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * j + 630 + i))
  fi
 done
done
