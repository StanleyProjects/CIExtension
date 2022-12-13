#!/bin/bash

echo "GitHub workflow tag test..."

. ex/util/require TAG

ex/github/tag/test.sh "$TAG"
if test $? -ne 0; then
 ex/github/workflow/tag/test/on_failed.sh; exit 11; fi
