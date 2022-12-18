#!/bin/bash

echo 'Workflow pull request unstable'

. ex/util/assert -s repository/internal/env
. repository/internal/env
. ex/util/require VERSION

TAG="${VERSION}-UNSTABLE"

ex/github/workflow/tag/test.sh "$TAG" || exit 1 # todo
repository/internal/shell/workflow/artifacts.sh "$TAG" || exit 2 # todo

echo 'Not implemented!'; exit 9 # todo
