#!/bin/bash

echo "Workflow verify assemble VCS..."

. ex/util/pipeline \
 ex/github/assemble/actions/run.sh \
 ex/github/assemble/actions/run/repository.sh \
 ex/github/assemble/repository/owner.sh \
 ex/github/assemble/repository/pages.sh \
 ex/github/assemble/worker.sh \
 ex/github/assemble/commit.sh
