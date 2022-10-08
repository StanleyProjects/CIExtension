#!/bin/bash

echo "Project diagnostics common..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

CODE=0
for ((ARG_NUMBER=1; ARG_NUMBER<=$#; ARG_NUMBER++)); do
 ENVIRONMENT="${!ARG_NUMBER}"
 . ex/util/require ENVIRONMENT
 . ex/util/assert -s "$ENVIRONMENT"
 echo "Start environment [$ARG_NUMBER/$#] ${ENVIRONMENT}..."
 ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
 SIZE=${#ARRAY[*]}
 for ((TYPE_INDEX=0; TYPE_INDEX<$SIZE; TYPE_INDEX++)); do
  TYPE="${ARRAY[TYPE_INDEX]}"
  . ex/util/require TYPE
  . ex/util/json -f "$ENVIRONMENT" \
   -sfs ".${TYPE}.task" TASK \
   -sfs ".${TYPE}.title" TITLE
  TYPE_NUMBER=$((TYPE_INDEX+1))
  echo "Task [$TYPE_NUMBER/$SIZE] verify \"$TITLE\"..."
  gradle -q -p "$REPOSITORY" "$TASK"; CODE=$?
  if test $CODE -ne 0; then
   . ex/util/json -f "$ENVIRONMENT" \
    -sfs ".${TYPE}.path" RELATIVE \
    -sfs ".${TYPE}.report" REPORT
   . ex/util/mkdirs "diagnostics/report/$RELATIVE"
   . ex/util/assert -d "$REPOSITORY/$REPORT"
   cp -r $REPOSITORY/$REPORT/* "diagnostics/report/$RELATIVE" \
    || . ex/util/throw 21 "Illegal state!"
   echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
    && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
    || . ex/util/throw $((100+TYPE_NUMBER)) "Illegal state!"
  fi
 done
done

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" \
 || . ex/util/throw 21 "Illegal state!"
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 0
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."
