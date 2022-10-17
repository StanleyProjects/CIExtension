#!/bin/bash

echo "Assemble GitHub worker..."

. ex/util/require VCS_DOMAIN VCS_PAT

. ex/util/mkdirs assemble/vcs

ENVIRONMENT='{}'
. ex/util/json_merge -v ENVIRONMENT \
 ".url=\"$VCS_DOMAIN/user\"" \
 '.output="assemble/vcs/worker.json"' \
 ".headers.Authorization=\"token $VCS_PAT\""
. ex/util/urlx "$ENVIRONMENT"

. ex/util/json -f assemble/vcs/worker.json \
 -si .id WORKER_ID \
 -sfs .login WORKER_LOGIN \
 -sfs .html_url WORKER_HTML_URL

WORKER_VCS_EMAIL="${WORKER_ID}+${WORKER_LOGIN}@users.noreply.github.com"

echo "$(jq ".vcs_email=\"$WORKER_VCS_EMAIL\"" assemble/vcs/worker.json)" > assemble/vcs/worker.json

echo "The worker $WORKER_HTML_URL is ready."
