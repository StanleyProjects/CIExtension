#!/bin/bash

echo 'Workflow pull request unstable'

. ex/util/assert -s repository/internal/env
. repository/internal/env
. ex/util/require VERSION

TAG="${VERSION}-UNSTABLE"

ex/github/workflow/tag/test.sh "$TAG" \
 && repository/internal/shell/workflow/artifacts.sh "$TAG" \
 && repository/internal/shell/workflow/pull/request/push.sh \
 && repository/internal/shell/workflow/github/release.sh \
 || . ex/util/throw 21 'Illegal state!'

echo 'Not implemented!'; exit 9 # todo
