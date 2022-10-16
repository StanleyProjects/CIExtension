#!/bin/bash

SCRIPT='ex/util/assert'
if [ ! -s "$SCRIPT" ]; then
 echo "Script \"$SCRIPT\" does not exist!"
 exit 1
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

QUERIES=('' '1' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=41
 ACTUAL=0
 $SCRIPT -eq ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit 141
 fi
done

QUERIES=('"" foo' 'foo ""' "'' foo" "foo ''")
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=42
 ACTUAL=0
 /bin/bash -c "$SCRIPT -eq ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit 142
 fi
done

export FOO='foo'
export BAR='bar'
export BAZ="$FOO"
[ "$FOO" == "$BAR" ] && . ex/util/throw 101 "Illegal state!"
[ "$FOO" != "$BAZ" ] && . ex/util/throw 101 "Illegal state!"

QUERIES=('FOO BAR' 'BAR FOO' 'BAZ BAR' 'BAR BAZ')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=43
 ACTUAL=0
 $SCRIPT -eq ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit 143
 fi
done

# -eqv
exit 1 # todo
# -s
exit 1 # todo
# -f
exit 1 # todo

echo "
Check success..."

# -d
exit 1 # todo
# -eq
exit 1 # todo
# -eqv
exit 1 # todo
# -s
exit 1 # todo
# -f
exit 1 # todo
