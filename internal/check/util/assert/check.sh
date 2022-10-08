#!/bin/bash

SCRIPT='ex/util/assert'
if [ ! -s "$SCRIPT" ]; then
 echo "Script \"$SCRIPT\" does not exist!"
 error 1
fi

echo "
Check error..."

EXPECTED=11
ACTUAL=0
$SCRIPT; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 101
fi

EXPECTED=12
ACTUAL=0
$SCRIPT ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 102
fi

EXPECTED=13
QUERIES=('1' 'a' 'foo')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20 + QUERY_INDEX))
 fi
done

# -d

EXPECTED=31
ACTUAL=0
$SCRIPT -d; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 111
fi

EXPECTED=142
ACTUAL=0
$SCRIPT -d ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 112
fi

EXISTING_DIRECTORY='/tmp'
if [ ! -d "$EXISTING_DIRECTORY" ]; then
 echo "Illegal state!"; exit 1; fi

EXPECTED=143
ACTUAL=0
$SCRIPT -d "$EXISTING_DIRECTORY" ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 113
fi

NOT_EXISTING_DIRECTORY="/tmp/$(date +%s)"
rm -rf "$NOT_EXISTING_DIRECTORY"
if test -d "$NOT_EXISTING_DIRECTORY"; then
 echo "Illegal state!"; exit 1; fi

EXPECTED=152
ACTUAL=0
$SCRIPT -d "$NOT_EXISTING_DIRECTORY"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 114
fi

EXPECTED=153
ACTUAL=0
$SCRIPT -d "$EXISTING_DIRECTORY" "$NOT_EXISTING_DIRECTORY"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 115
fi

# -eq
exit 1 # todo
# -s
exit 1 # todo

echo "
Check success..."

# -d
exit 1 # todo
# -eq
exit 1 # todo
# -s
exit 1 # todo
