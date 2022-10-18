#!/bin/bash

echo "Assemble GitHub repository pages..."

. ex/util/require VCS_PAT

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL \
 -sfs .html_url REPOSITORY_HTML_URL

. ex/util/mkdirs assemble/vcs/repository

ex/util/url -u "$REPOSITORY_URL/pages" \
 -o assemble/vcs/repository/pages.json \
 -h "Authorization: token $VCS_PAT"
 || . ex/util/throw 21 "Get pages $REPOSITORY_HTML_URL error!"

. ex/util/json -f assemble/vcs/repository/pages.json \
 -sfs .html_url REPOSITORY_PAGES_HTML_URL

echo "The pages $REPOSITORY_PAGES_HTML_URL is ready."
