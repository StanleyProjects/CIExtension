#!/bin/bash

echo 'Workflow pull request unstable setup'

. ex/util/pipeline \
 ex/github/assemble/repository.sh \
 ex/github/assemble/repository/owner.sh \
 ex/github/assemble/pr.sh \
 ex/github/assemble/worker.sh \
 ex/github/assemble/pr/commit.sh \
 ex/github/assemble/actions/run.sh
