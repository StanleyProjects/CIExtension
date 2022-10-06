#!/bin/bash

SCRIPT='ex/notification/telegram/send_file.sh'
if [ ! -s "$SCRIPT"]; then
 echo "Script \"$SCRIPT\" does not exist!"
 error 1
fi

echo "
Check error..."

EXPECTED=11
QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20 + QUERY_INDEX))
 fi
done

EXPECTED=101
ACTUAL=0
$SCRIPT 1; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 31
fi

export TELEGRAM_BOT_ID=foo
EXPECTED=102
ACTUAL=0
$SCRIPT 1; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 32
fi

export TELEGRAM_BOT_TOKEN=bar
EXPECTED=103
ACTUAL=0
$SCRIPT 1; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 33
fi

export TELEGRAM_CHAT_ID=baz
EXPECTED=104
QUERIES=('""' \'\')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 /bin/bash -c "$SCRIPT ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((40 + QUERY_INDEX))
 fi
done

FILE_PATH="/tmp/$(date +%s)"
if test -f "$FILE_PATH"; then
 echo "File \"$FILE_PATH\" exists!"
 exit 101
fi
EXPECTED=12
ACTUAL=0
$SCRIPT "$FILE_PATH"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 51
fi
FILE_PATH="/tmp/$(date +%s)"
touch "$FILE_PATH"
if [ ! -f "$FILE_PATH" ]; then
 echo "File \"$FILE_PATH\" does not exist!"
 exit 102
fi
if test -s "$FILE_PATH"; then
 echo "File \"$FILE_PATH\" is not empty!"
 exit 103
fi
EXPECTED=13
ACTUAL=0
$SCRIPT "$FILE_PATH"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 52
fi

FILE_PATH="/tmp/$(date +%s)"
echo "$(date +%s)" > "$FILE_PATH"
if [ ! -s "$FILE_PATH" ]; then
 echo "File \"$FILE_PATH\" does not exist!"
 exit 101
fi
EXPECTED=21
ACTUAL=0
$SCRIPT "$FILE_PATH"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 41
fi
TELEGRAM_BOT_ID=$CHECK_TELEGRAM_BOT_ID
ACTUAL=0
$SCRIPT "$FILE_PATH"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 42
fi
TELEGRAM_BOT_TOKEN=$CHECK_TELEGRAM_BOT_TOKEN
ACTUAL=0
$SCRIPT "$FILE_PATH"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 43
fi
TELEGRAM_CHAT_ID=$CHECK_TELEGRAM_CHAT_ID

echo "
Check success..."

. $SCRIPT "check notification telegram send message | $(date +%s)"
