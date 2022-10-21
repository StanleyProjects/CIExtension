#!/bin/bash

PREFIX='ex'
SCRIPTS=($(find "$PREFIX" -type f | sort -V))
SIZE=${#SCRIPTS[@]}
for ((SCRIPT_INDEX=0; SCRIPT_INDEX<$SIZE; SCRIPT_INDEX++)); do
 SCRIPT="${SCRIPTS[$SCRIPT_INDEX]}"
 if [[ ! "$SCRIPT" =~ ^$PREFIX/ ]]; then
  echo "Script format error!"; exit $((20 + SCRIPT_INDEX + 1)); fi
 RELATIVE="${SCRIPT/$PREFIX\//}"
 [[ "$RELATIVE" =~ .sh$ ]] && RELATIVE="${RELATIVE/.sh/}"
 SCRIPT_CHECK="internal/check/$RELATIVE/build.sh"
 if [ ! -s "$SCRIPT_CHECK" ]; then
  echo "Script check \"$SCRIPT_CHECK\" does not exist!"; exit $((60 + SCRIPT_INDEX + 1)); fi
 echo "Check [$((SCRIPT_INDEX + 1))/$SIZE] \"$PREFIX/$RELATIVE\"..."
 $SCRIPT_CHECK || exit $((100 + SCRIPT_INDEX + 1))
done
