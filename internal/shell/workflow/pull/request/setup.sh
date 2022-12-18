#!/bin/bash

echo 'Workflow pull request setup'

. ex/util/pipeline \
 repository/ex/github/assemble/repository.sh \
 repository/ex/github/assemble/repository/owner.sh \
 repository/ex/github/assemble/pr.sh \
 repository/ex/github/assemble/worker.sh \
 repository/ex/github/assemble/pr/commit.sh \
 repository/ex/github/assemble/actions/run.sh
