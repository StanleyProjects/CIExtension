#!/bin/bash

echo 'Workflow pull request prepare merge'

. ex/util/pipeline \
 repository/ex/github/assemble/repository.sh \
 repository/ex/github/assemble/worker.sh \
 repository/ex/github/assemble/pr.sh \
 repository/ex/github/workflow/pr/merge.sh
