#!/bin/bash

echo "Assemble GitHub actions run..."

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME CI_BUILD_ID

. ex/util/mkdirs assemble/vcs/actions

ex/util/url "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/actions/runs/$CI_BUILD_ID" \
 assemble/vcs/actions/run.json \
 || . ex/util/throw 21 "Get actions run \"$CI_BUILD_ID\" error!"

. ex/util/json -f assemble/vcs/actions/run.json \
 -sfs .html_url RUN_HTML_URL

echo "The actions run $RUN_HTML_URL is ready."
