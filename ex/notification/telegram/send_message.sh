#!/bin/bash

echo "Notification telegram send message..."

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11
fi

TELEGRAM_MESSAGE="$1"

. ex/util/require TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID TELEGRAM_MESSAGE

TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//"#"/"%23"}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//$'\n'/"%0A"}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//$'\r'/""}
TELEGRAM_MESSAGE=${TELEGRAM_MESSAGE//"_"/"\_"}

TELEGRAM_OUTPUT="/tmp/$(date +%s)"
TELEGRAM_CODE=0
TELEGRAM_CODE=$(curl -s -w %{http_code} --connect-timeout 4 -m 16 -o "$TELEGRAM_OUTPUT" \
 "https://api.telegram.org/bot${TELEGRAM_BOT_ID}:${TELEGRAM_BOT_TOKEN}/sendMessage" \
 -d chat_id="$TELEGRAM_CHAT_ID" \
 -d text="$TELEGRAM_MESSAGE" \
 -d parse_mode='markdown')

if test $TELEGRAM_CODE -ne 200; then
 echo "Send message error!"
 echo "Request error with response code $TELEGRAM_CODE!"
 cat "$TELEGRAM_OUTPUT"
 exit 21
fi
