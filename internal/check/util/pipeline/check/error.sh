#!/bin/bash

echo "
Check arguments..."

EXPECTED=11
ACTUAL=0
ex/util/pipeline; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 21
fi

echo "
Check empty commands..."

EXPECTED=21
ACTUAL=0
ex/util/pipeline '' 2; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 121
fi
EXPECTED=22
ACTUAL=0
ex/util/pipeline 'echo 1' ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 122
fi

echo "
Check error commands..."

ARRAY=(
 'exit 1'
 'foo'
 '1'
 '/bin/false'
)
for ((i=0; i<${#ARRAY[@]}; i++)); do
 EXPECTED=31
 ACTUAL=0
 ex/util/pipeline "${ARRAY[$i]}" 'echo 2'; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((1310+i))
 fi
 EXPECTED=32
 ACTUAL=0
 ex/util/pipeline 'echo 1' "${ARRAY[$i]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((1320+i))
 fi
done
