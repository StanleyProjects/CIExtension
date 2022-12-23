#!/bin/bash

EXPECTED=96
COVERED=0
SIZE=0

PREFIXES=(
 ci
 ex
 internal/shell
)
PREFIXES_SIZE=${#PREFIXES[@]}
if [[ $PREFIXES_SIZE < 1 ]]; then
 echo "Prefixes size error!"; exit 11; fi
for ((PREFIX_INDEX=0; PREFIX_INDEX<$PREFIXES_SIZE; PREFIX_INDEX++)); do
 PREFIX="${PREFIXES[$PREFIX_INDEX]}"
 SCRIPTS=($(find "$PREFIX" -type f | sort -V))
 SCRIPTS_SIZE=${#SCRIPTS[@]}
 if [[ $SCRIPTS_SIZE < 1 ]]; then
  echo "Scripts size error!"; exit 12; fi
 SIZE=$((SIZE + SCRIPTS_SIZE))
 for ((SCRIPT_INDEX=0; SCRIPT_INDEX<$SCRIPTS_SIZE; SCRIPT_INDEX++)); do
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
done

ACTUAL=$(((COVERED * 100) / SIZE))
if test $ACTUAL -lt $EXPECTED; then
 echo "Coverage error! Actual is ${ACTUAL}%, but expected is ${EXPECTED}%."
 exit 91
fi

echo "Test coverage - ${ACTUAL}%"
