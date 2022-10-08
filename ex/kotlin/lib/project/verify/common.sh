#!/bin/bash

echo "Project verify common..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

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
  gradle -q -p "$REPOSITORY" "$TASK" \
   || . ex/util/throw $((100+TYPE_NUMBER)) "Task [$TYPE_NUMBER/$SIZE] verify \"$TITLE\" error!"
 done
done
