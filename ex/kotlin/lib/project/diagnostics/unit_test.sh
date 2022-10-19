#!/bin/bash

echo "Project diagnostics unit test..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
ENVIRONMENT="$JSON_PATH/verify/unit_test.json"
. ex/util/assert -s "$ENVIRONMENT"

TYPE="UNIT_TEST"
. ex/util/json -f "$ENVIRONMENT" \
 -sfs ".${TYPE}.task" TASK \
 -sfs ".${TYPE}.title" TITLE

CODE=0
echo "Task verify \"$TITLE\"..."
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
  || . ex/util/throw 22 "Illegal state!"
else
 TYPE="TEST_COVERAGE"
 . ex/util/json -f "$ENVIRONMENT" \
  -sfs ".${TYPE}.task" TASK \
  -sfs ".${TYPE}.title" TITLE
 echo "Task \"$TITLE\"..."
 gradle -q -p "$REPOSITORY" "$TASK" \
  || . ex/util/throw 31 "Illegal state!"
 . ex/util/json -f "$ENVIRONMENT" \
  -sfs ".${TYPE}.verification.task" TASK
 echo "Task verify \"$TITLE\"..."
 gradle -q -p "$REPOSITORY" "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  . ex/util/json -f "$ENVIRONMENT" \
   -sfs ".${TYPE}.path" RELATIVE \
   -sfs ".${TYPE}.report" REPORT
  . ex/util/mkdirs "diagnostics/report/$RELATIVE"
  . ex/util/assert -d "$REPOSITORY/$REPORT"
  cp -r $REPOSITORY/$REPORT/* "diagnostics/report/$RELATIVE" \
   || . ex/util/throw 32 "Illegal state!"
  echo "$(jq -Mc ".$TYPE.path=\"$RELATIVE\"" diagnostics/summary.json)" > diagnostics/summary.json \
   && echo "$(jq -Mc ".$TYPE.title=\"$TITLE\"" diagnostics/summary.json)" > diagnostics/summary.json \
   || . ex/util/throw 33 "Illegal state!"
 fi
fi

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" \
 || . ex/util/throw 41 "Illegal state!"
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"
else
 echo "Diagnostics have determined the cause of the failure - this is: $TYPES."
fi
