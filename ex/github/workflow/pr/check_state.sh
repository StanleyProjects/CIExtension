#!/bin/bash

echo "GitHub workflow pull request check state..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

for ((TRY_INDEX=0; TRY_INDEX<10; TRY_INDEX++ )); do
 ex/github/pr/check_state.sh "$EXPECTED_STATE" && exit 0
 echo "The check failed for the $TRY_INDEX time..."
 sleep 1
done

echo "The pull request #$PR_NUMBER state is not \"$EXPECTED_STATE\"!"

exit 12
