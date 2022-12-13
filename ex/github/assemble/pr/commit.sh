#!/bin/bash

echo "GitHub assemble pull request commit..."

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL

. ex/util/require PR_NUMBER

. ex/util/json -f assemble/vcs/pr${PR_NUMBER}.json \
 -sfs .head.sha GIT_COMMIT_SRC \
 -sfs .base.sha GIT_COMMIT_DST

mkdir -p assemble/vcs/commit \
 || . ex/util/throw 11 "Illegal state!"

ex/util/url -u "$REPOSITORY_URL/commits/$GIT_COMMIT_SRC" \
 -o assemble/vcs/commit.src.json \
 || . ex/util/throw 21 "Get commit source $GIT_COMMIT_SRC info error!"

. ex/util/json -f assemble/vcs/commit.src.json \
 -sfs .html_url COMMIT_HTML_URL \
 -sfs .author.login AUTHOR_LOGIN

echo "The commit source $COMMIT_HTML_URL is ready."

ex/util/url -u "$VCS_DOMAIN/users/$AUTHOR_LOGIN" \
 -o assemble/vcs/commit/author.src.json \
 || . ex/util/throw 22 "Get author source $AUTHOR_LOGIN info error!"

. ex/util/json -f assemble/vcs/commit/author.src.json \
 -sfs .html_url AUTHOR_HTML_URL

echo "The author source $AUTHOR_HTML_URL is ready."

ex/util/url -u "$REPOSITORY_URL/commits/$GIT_COMMIT_DST" \
 -o assemble/vcs/commit.dst.json \
 || . ex/util/throw 23 "Get commit destination $GIT_COMMIT_DST info error!"

. ex/util/json -f assemble/vcs/commit.dst.json \
 -sfs .html_url COMMIT_HTML_URL \
 -sfs .author.login AUTHOR_LOGIN

echo "The commit destination $COMMIT_HTML_URL is ready."

ex/util/url -u "$VCS_DOMAIN/users/$AUTHOR_LOGIN" \
 -o assemble/vcs/commit/author.dst.json \
 || . ex/util/throw 24 "Get author destination $AUTHOR_LOGIN info error!"

. ex/util/json -f assemble/vcs/commit/author.dst.json \
 -sfs .html_url AUTHOR_HTML_URL

echo "The author destination $AUTHOR_HTML_URL is ready."
