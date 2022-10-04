#!/bin/bash

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
 SCRIPT_CHECK="internal/check/$RELATIVE/build.sh"
 if test -s "$SCRIPT_CHECK"; then
  echo "Check $((SCRIPT_INDEX + 1))/$SIZE"
  exit 1 #todo
  $SCRIPT_CHECK || exit 21
 else
  echo "Script check \"$SCRIPT_CHECK\" does not exist!"; exit 22
 fi
done
