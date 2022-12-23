#!/bin/bash

PREFIXES=(
ex/github/diagnostics
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
 for ((SCRIPT_INDEX=0; SCRIPT_INDEX<$SCRIPTS_SIZE; SCRIPT_INDEX++)); do
  SCRIPT="${SCRIPTS[$SCRIPT_INDEX]}"
  if [[ ! "$SCRIPT" =~ ^$PREFIX/ ]]; then
   echo "Script format error!"; exit $((20 + SCRIPT_INDEX + 1)); fi
  RELATIVE="$SCRIPT"
  [[ "$RELATIVE" =~ .sh$ ]] && RELATIVE="${RELATIVE/.sh/}"
  SCRIPT_CHECK="internal/check/$RELATIVE/build.sh"
  if [ ! -s "$SCRIPT_CHECK" ]; then
   echo "Script check \"$SCRIPT_CHECK\" does not exist!"; exit $((60 + SCRIPT_INDEX + 1)); fi
  echo "Check [$((SCRIPT_INDEX + 1))/$SCRIPTS_SIZE] \"$RELATIVE\"..."
  $SCRIPT_CHECK || exit $((100 + SCRIPT_INDEX + 1))
 done
done
