#!/bin/bash

echo "Assemble GitHub repository pages..."

. ex/util/require VCS_PAT

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL \
 -sfs .html_url REPOSITORY_HTML_URL

. ex/util/mkdirs assemble/vcs/repository

CODE=0
CODE=$(curl -s -w %{http_code} -o assemble/vcs/repository/pages.json \
 "$REPOSITORY_URL/pages" \
 -H "Authorization: token $VCS_PAT")
if test $CODE -ne 200; then
 echo "Get pages $REPOSITORY_HTML_URL error!"
 echo "Request error with response code $CODE!"
 exit 21
fi


. ex/util/json -f assemble/vcs/repository/pages.json \
 -sfs .html_url REPOSITORY_PAGES_HTML_URL

echo "The pages $REPOSITORY_PAGES_HTML_URL is ready."
