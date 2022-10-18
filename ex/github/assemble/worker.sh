#!/bin/bash

echo "Assemble GitHub worker..."

. ex/util/require VCS_DOMAIN VCS_PAT

. ex/util/mkdirs assemble/vcs

ex/util/url -u "$VCS_DOMAIN/user" \
 -o assemble/vcs/worker.json \
 -h "Authorization: token $VCS_PAT"
 || . ex/util/throw 21 "Get worker error!"

. ex/util/json -f assemble/vcs/worker.json \
 -si .id WORKER_ID \
 -sfs .login WORKER_LOGIN \
 -sfs .html_url WORKER_HTML_URL

WORKER_VCS_EMAIL="${WORKER_ID}+${WORKER_LOGIN}@users.noreply.github.com"

echo "$(jq ".vcs_email=\"$WORKER_VCS_EMAIL\"" assemble/vcs/worker.json)" > assemble/vcs/worker.json

echo "The worker $WORKER_HTML_URL is ready."
