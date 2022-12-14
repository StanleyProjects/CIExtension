#!/bin/bash

echo "Assemble GitHub repository owner..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .owner.url REPOSITORY_OWNER_URL

. ex/util/mkdirs assemble/vcs/repository

ex/util/url -u "$REPOSITORY_OWNER_URL" \
 -o assemble/vcs/repository/owner.json \
 || . ex/util/throw 21 "Get repository owner $REPOSITORY_OWNER_URL error!"

. ex/util/json -f assemble/vcs/repository/owner.json \
 -sfs .html_url REPOSITORY_OWNER_HTML_URL

echo "The repository owner $REPOSITORY_OWNER_HTML_URL is ready."
