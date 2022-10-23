#!/bin/bash

echo "Assemble GitHub pull request..."

. ex/util/require PR_NUMBER

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

. ex/util/mkdirs assemble/vcs

ARTIFACT="assemble/vcs/pr${PR_NUMBER}.json"
ex/util/url -u "$REPOSITORY_URL/pulls/$PR_NUMBER" -o "$ARTIFACT" \
 || . ex/util/throw 21 "Get pull request #$PR_NUMBER error!"

. ex/util/json -f "$ARTIFACT" \
 -sfs .html_url PR_HTML_URL

echo "The pull request $PR_HTML_URL is ready."
