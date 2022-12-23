#!/bin/bash

SCRIPT='ex/notification/telegram/send_file.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

$SCRIPT 1; . ex/util/assert -eqv $? 101

export TELEGRAM_BOT_ID=foo
$SCRIPT 1; . ex/util/assert -eqv $? 102

export TELEGRAM_BOT_TOKEN=bar
$SCRIPT 1; . ex/util/assert -eqv $? 103

export TELEGRAM_CHAT_ID=baz
QUERIES=('""' \'\')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT ${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 104
done

FILE_PATH="/tmp/$(date +%s)"
[ -f "$FILE_PATH" ] . ex/util/throw 101 "File \"$FILE_PATH\" exists!"

$SCRIPT "$FILE_PATH"; . ex/util/assert -eqv $? 12

FILE_PATH="/tmp/$(date +%s)"
touch "$FILE_PATH"
[ ! -f "$FILE_PATH" ] . ex/util/throw 102 "File \"$FILE_PATH\" does not exist!"
[ -s "$FILE_PATH" ] . ex/util/throw 103 "File \"$FILE_PATH\" is not empty!"

$SCRIPT "$FILE_PATH"; . ex/util/assert -eqv $? 13

FILE_PATH="/tmp/$(date +%s)"
echo "$(date +%s)" > "$FILE_PATH"
[ ! -s "$FILE_PATH" ] . ex/util/throw 104 "File \"$FILE_PATH\" does not exist!"

$SCRIPT "$FILE_PATH"; . ex/util/assert -eqv $? 21

TELEGRAM_BOT_ID=$CHECK_TELEGRAM_BOT_ID
$SCRIPT "$FILE_PATH"; . ex/util/assert -eqv $? 21

TELEGRAM_BOT_TOKEN=$CHECK_TELEGRAM_BOT_TOKEN
$SCRIPT "$FILE_PATH"; . ex/util/assert -eqv $? 21

TELEGRAM_CHAT_ID=$CHECK_TELEGRAM_CHAT_ID

echo "
Check success..."

. $SCRIPT "$FILE_PATH"
