#!/bin/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument, but actual is $#!"; exit 11
fi

URL_BASE="$1"
DESTINATION="$2"

for REQUIRE_ARGUMENT in URL_BASE DESTINATION
 do if test -z "${!REQUIRE_ARGUMENT}"; then
  echo "Argument \"$REQUIRE_ARGUMENT\" is empty!"; exit 12; fi done

if test -d "$DESTINATION"; then
 echo "Destination \"$DESTINATION\" is directory!"
 exit 21
fi

HTTP_CODE=0
HTTP_CODE=$(curl -s -w %{http_code} --connect-timeout 4 -m 16 -o "$DESTINATION" "$URL_BASE" \
 -H "Authorization: token $VCS_PAT")
if test $HTTP_CODE -ne 200; then
 echo "Request error with response code \"$HTTP_CODE\"!"
 exit 22
fi
