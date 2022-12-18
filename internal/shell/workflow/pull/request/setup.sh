#!/bin/bash

echo 'Workflow pull request setup'

. ex/util/pipeline \
 ex/github/assemble/actions/run.sh \
 ex/github/assemble/actions/run/repository.sh \
 ex/github/assemble/repository/owner.sh \
 ex/github/assemble/worker.sh \
 ex/github/assemble/pr.sh \
 ex/github/assemble/pr/commit.sh
