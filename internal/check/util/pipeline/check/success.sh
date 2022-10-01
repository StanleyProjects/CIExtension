#!/bin/bash

CODE=0
ex/util/pipeline \
 'exit 0' \
 'echo 1' \
 'echo 2' \
 'echo 3'; CODE=$?

if test $CODE -ne 0; then
 echo "Pipeline error!"; exit 21
fi

. ex/util/pipeline \
 'exit 0' \
 'echo a' \
 'echo b' \
 'echo c'
