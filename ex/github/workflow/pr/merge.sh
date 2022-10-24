#!/bin/bash

echo "GitHub workflow pr merge..."

. ex/util/require PR_NUMBER

. ex/util/json -f "assemble/vcs/pr${PR_NUMBER}.json" \
 -sfs .head.sha GIT_COMMIT_SRC \
 -sfs .base.ref GIT_BRANCH_DST

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .vcs_email WORKER_VCS_EMAIL

REPOSITORY='repository'
. ex/util/assert -d "$REPOSITORY"

git -C "$REPOSITORY" config user.name "$WORKER_NAME" \
 && git -C "$REPOSITORY" config user.email "$WORKER_VCS_EMAIL" \
 || . ex/util/throw 21 "Git config error!"

echo "Fetch ${GIT_BRANCH_DST}..."
git -C "$REPOSITORY" fetch origin "$GIT_BRANCH_DST" \
 || . ex/util/throw 22 "Git fetch \"$GIT_BRANCH_DST\" error!"

echo "Checkout ${GIT_BRANCH_DST}..."
git -C "$REPOSITORY" checkout "$GIT_BRANCH_DST" \
 || . ex/util/throw 23 "Git checkout to \"$GIT_BRANCH_DST\" error!"

echo "Merge ${GIT_COMMIT_SRC::7} -> \"${GIT_BRANCH_DST}\"..."
git -C "$REPOSITORY" merge --no-ff --no-commit "$GIT_COMMIT_SRC" \
 || . ex/util/throw 24 "Merge ${GIT_COMMIT_SRC::7} -> \"$GIT_BRANCH_DST\" error!"
