#!/bin/bash

echo "Assemble GitHub repository..."

. ex/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME

mkdir -p assemble/vcs \
 || . ex/util/throw 11 "Illegal state!"

ex/util/url "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME" \
 assemble/vcs/repository.json \
 || . ex/util/throw 21 "Get repository \"$REPOSITORY_NAME\" error!"

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .html_url REPOSITORY_HTML_URL

echo "The repository $REPOSITORY_HTML_URL is ready."
