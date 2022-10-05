#!/bin/bash

echo "Assemble GitHub repository owner..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .owner.url REPOSITORY_OWNER_URL

mkdir -p assemble/vcs/repository \
 || . ex/util/throw 11 "Illegal state!"

ex/util/url "$REPOSITORY_OWNER_URL" \
 assemble/vcs/repository/owner.json \
 || . ex/util/throw 21 "Get repository owner $REPOSITORY_OWNER_URL error!"

. ex/util/json -f assemble/vcs/repository/owner.json \
 -sfs .html_url REPOSITORY_OWNER_HTML_URL

echo "The repository owner $REPOSITORY_OWNER_HTML_URL is ready."
