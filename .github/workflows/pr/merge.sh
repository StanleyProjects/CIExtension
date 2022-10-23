#!/bin/bash

REPOSITORY='repository'
. ex/util/assert -d "$REPOSITORY"

. ex/util/pipeline \
 "$REPOSITORY"/ex/github/assemble/worker.sh \
 "$REPOSITORY"/ex/github/assemble/repository.sh \
 "$REPOSITORY"/ex/github/assemble/pr.sh \
 "$REPOSITORY"/ex/github/workflow/pr/merge.sh
