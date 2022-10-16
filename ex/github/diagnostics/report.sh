#!/bin/bash

echo "GitHub diagnostics report..."

. ex/util/require VCS_PAT

. ex/util/assert -s diagnostics/summary.json

REPOSITORY=pages/diagnostics/report
. ex/util/mkdirs "$REPOSITORY"

. ex/util/json -f assemble/vcs/actions/run.json \
 -si .id CI_BUILD_ID \
 -si .run_number CI_BUILD_NUMBER

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

. ex/util/json -f assemble/vcs/repository/pages.json \
 -sfs .html_url REPOSITORY_PAGES_HTML_URL

TYPES="$(jq -Mcer keys diagnostics/summary.json)" \
 || . ex/util/throw 21 "Illegal state!"
if test "$TYPES" == "[]"; then
 . ex/util/throw 22 "Diagnostics should have determined the cause of the failure!"
fi

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin \
  "${REPOSITORY_CLONE_URL//'://'/"://${VCS_PAT}@"}" \
 && git -C "$REPOSITORY" fetch --depth=1 origin gh-pages \
 && git -C "$REPOSITORY" checkout gh-pages \
 || . ex/util/throw 31 "Git checkout error!"

RELATIVE_PATH="$CI_BUILD_NUMBER/$CI_BUILD_ID/diagnostics/report"
. ex/util/mkdirs "$REPOSITORY/build/$RELATIVE_PATH"
cp -r diagnostics/report/* "$REPOSITORY/build/$RELATIVE_PATH" \
 || . ex/util/throw 32 "Illegal state!"

. ex/util/json -f assemble/vcs/worker.json \
 -sfs .name WORKER_NAME \
 -sfs .vcs_email WORKER_VCS_EMAIL

COMMIT_MESSAGE="CI build #$CI_BUILD_NUMBER | $WORKER_NAME added diagnostics report of ${TYPES} issues."

git -C "$REPOSITORY" config user.name "$WORKER_NAME" \
 && git -C "$REPOSITORY" config user.email "$WORKER_VCS_EMAIL" \
 || . ex/util/throw 41 "Git config error!"

echo "Git commit..."
git -C "$REPOSITORY" add --all . \
 && git -C "$REPOSITORY" commit -m "$COMMIT_MESSAGE" \
 && git -C "$REPOSITORY" tag -a "diagnostics/report/$CI_BUILD_NUMBER/$CI_BUILD_ID" \
  -m "${REPOSITORY_PAGES_HTML_URL}build/$RELATIVE_PATH" \
 || . ex/util/throw 42 "Git commit error!"

echo "Git push..."
git -C "$REPOSITORY" push \
 && git -C "$REPOSITORY" push --tag \
 || . ex/util/throw 43 "Git push error!"
