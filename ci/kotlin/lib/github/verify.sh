#!/bin/bash

echo "Workflow verify..."

. ex/util/pipeline \
 ci/workflow/verify/assemble/vcs.sh \
 ci/workflow/verify/project/prepare.sh \
 ci/workflow/verify/check.sh \
 ci/workflow/verify/on_success.sh
