#!/bin/bash

FILE='sample.json'

if [ ! -s "$FILE" ]; then
 echo "The file \"$FILE\" does not exist!"; exit 11
fi

rm "${FILE}.empty"
touch "${FILE}.empty"

if [ ! -f "${FILE}.empty" ]; then
 echo "The file \"${FILE}.empty\" does not exist!"; exit 12
elif test -s "${FILE}.empty"; then
 echo "The file \"${FILE}.empty\" does not empty!"; exit 13
fi

if test -s "${FILE}.not"; then
 echo "The file \"${FILE}.not\" exists!"; exit 14
fi

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

EXPECTED=121
ACTUAL=0
ex/util/json -j "" 1 2 3; ACTUAL=$?
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
