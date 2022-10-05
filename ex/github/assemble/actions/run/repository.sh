#!/bin/bash

echo "Assemble GitHub actions run repository..."

. ex/util/json -f assemble/vcs/actions/run.json \
 -sfs .repository.url REPOSITORY_URL \
 -sfs .repository.name REPOSITORY_NAME

ex/util/url "$REPOSITORY_URL" \
 assemble/vcs/repository.json \
 || . ex/util/throw 21 "Get repository \"$REPOSITORY_NAME\" error!"

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .html_url REPOSITORY_HTML_URL

echo "The repository $REPOSITORY_HTML_URL is ready."
