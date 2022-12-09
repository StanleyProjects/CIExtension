#!/bin/bash

[ ! -z "$VERSION" ] && . ex/util/throw 101 "Illegal state!"
. ex/util/assert -s internal/env
. internal/env
. ex/util/require VERSION

ISSUER='README.md'
. ex/util/assert -s "$ISSUER"
LINES_EXPECTED=(
 "![version](https://img.shields.io/static/v1?label=version&message=${VERSION}&labelColor=212121&color=2962ff&style=flat)"
)
LINES_ACTUAL=($(cat "$ISSUER"))
for ((EXPECTED_INDEX=0; EXPECTED_INDEX<${#LINES_EXPECTED[@]}; EXPECTED_INDEX++)); do
 EXISTS='false'
 EXPECTED_LINE="${LINES_EXPECTED[$EXPECTED_INDEX]}"
 for ((ACTUAL_INDEX=0; ACTUAL_INDEX<${#LINES_ACTUAL[@]}; ACTUAL_INDEX++)); do
  if test "$EXPECTED_LINE" == "${LINES_ACTUAL[$ACTUAL_INDEX]}"; then
   EXISTS='true'; break; fi
 done
 case "$EXISTS" in
  'true') /bin/true;;
  'false') . ex/util/throw 21 "The file \"$ISSUER\" does not contain the line \"$EXPECTED_LINE\"!";;
  *) echo "Not implemented!"; exit 1;;
 esac
done

echo "All checks of the file \"$ISSUER\" were successful."
