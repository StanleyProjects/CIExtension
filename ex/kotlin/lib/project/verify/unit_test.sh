#!/bin/bash

echo "Project verify unit test..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
ENVIRONMENT="$JSON_PATH/verify/unit_test.json"
. ex/util/assert -s "$ENVIRONMENT"

TYPE="UNIT_TEST"
. ex/util/json -f "$ENVIRONMENT" -sfs ".${TYPE}.task" TASK
echo "Task verify \"$TASK\"..."
gradle -q -p "$REPOSITORY" "$TASK" \
 || . ex/util/throw 21 "Unit test error!"

TYPE="TEST_COVERAGE"
. ex/util/json -f "$ENVIRONMENT" -sfs ".${TYPE}.task" TASK
echo "Task verify \"$TASK\"..."
gradle -q -p "$REPOSITORY" "$TASK" \
 || . ex/util/throw 31 "Illegal state!"
. ex/util/json -f "$ENVIRONMENT" -sfs ".${TYPE}.verification.task" TASK
echo "Task verify \"$TASK\"..."
gradle -q -p "$REPOSITORY" "$TASK" \
 || . ex/util/throw 22 "Test coverage verification error!"
