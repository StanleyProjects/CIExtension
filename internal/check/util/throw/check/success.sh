#!/bin/bash

ARRAY=(1 42 255)
for ((i=0; i<${#ARRAY[@]}; i++)); do
 EXPECTED=${ARRAY[$i]}
 ACTUAL=0
 ex/util/throw $EXPECTED 'foo'; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((100+i))
 fi
done
