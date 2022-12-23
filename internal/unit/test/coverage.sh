#!/bin/bash

EXPECTED=96
COVERED=0
PREFIX='ex'
SCRIPTS=($(find "$PREFIX" -type f | sort -V))
SIZE=${#SCRIPTS[@]}
for ((SCRIPT_INDEX=0; SCRIPT_INDEX<$SIZE; SCRIPT_INDEX++)); do
 SCRIPT="${SCRIPTS[$SCRIPT_INDEX]}"
 if [[ ! "$SCRIPT" =~ ^$PREFIX/ ]]; then
  echo "Script format error!"; exit $((20 + SCRIPT_INDEX + 1)); fi
 RELATIVE="$SCRIPT"
 [[ "$RELATIVE" =~ .sh$ ]] && RELATIVE="${RELATIVE/.sh/}"
 if [ -s "internal/check/$RELATIVE/build.sh" ] \
  && [ -s "internal/check/$RELATIVE/check.sh" ] \
  && [ -s "internal/check/$RELATIVE/Dockerfile" ]; then
  COVERED=$((COVERED + 1))
 else
  echo "Script \"$SCRIPT\" does not covered!"
 fi
done

ACTUAL=$(((COVERED * 100) / SIZE))
if test $ACTUAL -lt $EXPECTED; then
 echo "Coverage error! Actual is ${ACTUAL}%, but expected is ${EXPECTED}%."
 exit 91
fi

echo "Test coverage - ${ACTUAL}%"
