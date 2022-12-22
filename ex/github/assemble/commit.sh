#!/bin/bash

echo "Assemble GitHub commit..."

REPOSITORY='repository'

. ex/util/assert -d "$REPOSITORY"

GIT_COMMIT_SHA="$(git -C "$REPOSITORY" rev-parse HEAD)" \
 || . ex/util/throw 11 "Get commit SHA error!"

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL \
 -sfs .html_url REPOSITORY_HTML_URL

. ex/util/mkdirs assemble/vcs/commit

ex/util/url -u "$REPOSITORY_URL/commits/$GIT_COMMIT_SHA" \
 -o assemble/vcs/commit.json \
 || . ex/util/throw 21 "Get commit $GIT_COMMIT_SHA error!"

. ex/util/json -f assemble/vcs/commit.json \
 -sfs .html_url COMMIT_HTML_URL \
 -sfs .author.url AUTHOR_URL \
 -sfs .author.login AUTHOR_LOGIN

echo "The commit $COMMIT_HTML_URL is ready."

ex/util/url -u "$AUTHOR_URL" \
 -o assemble/vcs/commit/author.json \
 || . ex/util/throw 22 "Get author \"$AUTHOR_LOGIN\" error!"

. ex/util/json -f assemble/vcs/commit/author.json \
 -sfs .html_url AUTHOR_HTML_URL

echo "The author $AUTHOR_HTML_URL is ready."
