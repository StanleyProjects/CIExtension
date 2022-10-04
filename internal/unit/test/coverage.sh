#!/bin/bash

EXPECTED=96
COVERED=0
PREFIX='ex'
SCRIPTS=($(find "$PREFIX" -type f))
SIZE=${#SCRIPTS[@]}
for ((SCRIPT_INDEX=0; SCRIPT_INDEX<$SIZE; SCRIPT_INDEX++)); do
 SCRIPT="${SCRIPTS[$SCRIPT_INDEX]}"
 EXPRESSION="^$PREFIX/"
 if [[ "$SCRIPT" =~ $EXPRESSION ]]; then
  RELATIVE="${SCRIPT/"$PREFIX"\//}"
 else
  exit 1 #todo
 fi
 EXPRESSION="\.sh$"
 if [[ "$RELATIVE" =~ $EXPRESSION ]]; then
  RELATIVE="${RELATIVE/".sh"/}"
 fi
 if test -s "internal/check/$RELATIVE/build.sh"; then
  COVERED=$((COVERED + 1))
 else
  echo "Script $SCRIPT does not covered!"
 fi
done

ACTUAL=$(((COVERED * 100) / SIZE))
if test $ACTUAL -lt $EXPECTED; then
 echo "Coverage error! Actual is $ACTUAL, but expected is $EXPECTED."
 exit 21
fi
