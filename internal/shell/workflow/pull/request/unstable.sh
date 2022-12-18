#!/bin/bash

echo 'Workflow pull request unstable'

. ex/util/assert -s internal/env
. internal/env
. ex/util/require VERSION

ex/github/workflow/tag/test.sh "${VERSION}-UNSTABLE"

echo 'Not implemented!'; exit 3 # todo
