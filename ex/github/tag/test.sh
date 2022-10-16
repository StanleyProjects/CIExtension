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

OUTPUT="/tmp/$(date +%s)"
TAG_ENCODED="$(echo "$TAG" | base64)"

CODE=0
CODE=$(curl -s -w %{http_code} -o "$OUTPUT" "$REPOSITORY_URL/git/refs/tags/$TAG")
case $CODE in
 404) echo "The tag \"$TAG\" does not exist yet in ${REPOSITORY_HTML_URL}."; exit 0;;
 200) mv "$OUTPUT" "assemble/tag${TAG_ENCODED}.json";;
 *) echo "Get tag \"$TAG\" info error!"
  . ex/util/throw 31 "Request error with response code $CODE!";;
esac

TYPE="$(jq -Mcer type "assemble/tag${TAG_ENCODED}.json")" || . ex/util/throw 101 "Illegal state!"
case $TYPE in
 object)
  . ex/util/json -f "assemble/tag${TAG_ENCODED}.json" -sfs .ref REF
  ex/util/assert -eqv "$REF" "refs/tags/$TAG" \
   && . ex/util/throw 41 "The tag \"$TAG\" already exists!"
  . ex/util/throw 102 "Illegal state!";;
 array)
  REFS=($(jq -Mcer ".[].ref" "assemble/tag${TAG_ENCODED}.json")) || . ex/util/throw 103 "Illegal state!"
  for ((REF_INDEX = 0; REF_INDEX < ${#REFS[*]}; REF_INDEX++)); do
   [ "${REFS[$REF_INDEX]}" == "refs/tags/$TAG" ] \
    && . ex/util/throw $((110 + REF_INDEX + 1)) "The tag \"$TAG\" already exists!"
  done; exit 0;;
 *) . ex/util/throw 61 "The type \"$TYPE\" is not supported!";;
esac

. ex/util/throw 104 "Illegal state!"
