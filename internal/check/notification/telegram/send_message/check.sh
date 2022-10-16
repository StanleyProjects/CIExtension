#!/bin/bash

SCRIPT='ex/notification/telegram/send_message.sh'
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

$SCRIPT 'foo'; . ex/util/assert -eqv $? 21

TELEGRAM_BOT_ID=$CHECK_TELEGRAM_BOT_ID
$SCRIPT 'foo'; . ex/util/assert -eqv $? 21

TELEGRAM_BOT_TOKEN=$CHECK_TELEGRAM_BOT_TOKEN
$SCRIPT 'foo'; . ex/util/assert -eqv $? 21

TELEGRAM_CHAT_ID=$CHECK_TELEGRAM_CHAT_ID

echo "
Check success..."

. $SCRIPT "check notification telegram send message | $(date +%s)"
