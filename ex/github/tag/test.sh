#!/bin/bash

echo "GitHub tag test..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11
fi

TAG="$1"

. ex/util/require TAG

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .url REPOSITORY_URL \
 -sfs .html_url REPOSITORY_HTML_URL

CODE=0
CODE=$(curl -s -w %{http_code} -o /tmp/tag.json "$REPOSITORY_URL/git/refs/tags/$TAG")
case $CODE in
 404)
  echo "The tag \"$TAG\" does not exist yet in ${REPOSITORY_HTML_URL}."
  exit 0;;
 200) true;; # ignored
 *) echo "Get tag \"$TAG\" info error!"
  . ex/util/throw 31 "Request error with response code $CODE!";;
esac

TYPE="$(jq -Mcer type /tmp/tag.json)" || . ex/util/throw 101 "Illegal state!"
case $TYPE in
 object)
  . ex/util/json -f /tmp/tag.json -sfs .ref REF
  ex/util/assert -eqv "$REF" "refs/tags/$TAG" \
   && . ex/util/throw 41 "The tag \"$TAG\" already exists!"
  . ex/util/throw 102 "Illegal state!";;
 array)
  REFS=($(jq -Mcer ".[].ref" /tmp/tag.json)) || . ex/util/throw 103 "Illegal state!"
  SIZE=${#REFS[*]}
  for ((REF_INDEX = 0; REF_INDEX < SIZE; REF_INDEX++)); do
   REF="${REFS[$REF_INDEX]}"
   ex/util/assert -eqv "$REF" "refs/tags/$TAG" \
    && . ex/util/throw 51 "The tag \"$TAG\" already exists!"
  done; exit 0;;
 *) . ex/util/throw 61 "The type \"$TYPE\" is not supported!";;
esac

. ex/util/throw 104 "Illegal state!"
