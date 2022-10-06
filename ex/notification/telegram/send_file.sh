#!/bin/bash

echo "Notification telegram send file..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11
fi

TELEGRAM_FILE="$1"

. ex/util/require TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID TELEGRAM_FILE

if [ ! -f "$TELEGRAM_FILE" ]; then
 echo "File \"$TELEGRAM_FILE\" does not exist!"; exit 12
elif [ ! -s "$TELEGRAM_FILE" ]; then
 echo "File \"$TELEGRAM_FILE\" is empty!"; exit 13
fi

TELEGRAM_OUTPUT="/tmp/$(date +%s)"
TELEGRAM_CODE=0
TELEGRAM_CODE=$(curl -s -w %{http_code} --connect-timeout 4 -m 16 -o "$TELEGRAM_OUTPUT" \
 -F document=@"$TELEGRAM_FILE" \
 "https://api.telegram.org/bot${TELEGRAM_BOT_ID}:${TELEGRAM_BOT_TOKEN}/sendDocument?chat_id=$TELEGRAM_CHAT_ID")

if test $TELEGRAM_CODE -ne 200; then
 echo "Send file error!"
 echo "Request error with response code $TELEGRAM_CODE!"
 cat "$TELEGRAM_OUTPUT"
 exit 21
fi
