#!/bin/bash

echo "GitHub workflow pull request check state..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

EXPECTED_STATE="$1"

. ex/util/require PR_NUMBER EXPECTED_STATE

MAX_INDEX=8
for ((TRY_INDEX=0; TRY_INDEX<$MAX_INDEX; TRY_INDEX++)); do
 CODE=0
 ex/github/pr/check_state.sh "$EXPECTED_STATE"; CODE=$?
 [ $CODE == 0 ] && exit 0
 [ $CODE != 21 ] && . ex/util/throw 102 'Illegal state!'
 echo "The check failed for the $TRY_INDEX time..."
 sleep 3
done

echo "The pull request #$PR_NUMBER state is not \"$EXPECTED_STATE\"!"

exit 12
