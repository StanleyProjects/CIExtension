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
export BAR2="$BAR"
[ "$FOO" == "$BAR" ] && . ex/util/throw 101 "Illegal state!"
[ "$FOO" != "$BAZ" ] && . ex/util/throw 101 "Illegal state!"
[ "$BAR" != "$BAR2" ] && . ex/util/throw 101 "Illegal state!"

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

QUERIES=('' '1' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=51
 ACTUAL=0
 $SCRIPT -eqv ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit 151
 fi
done

QUERIES=(
 '"" foo' 'foo ""' "'' foo" "foo ''"
 '"$FOO" "$BAR"' '"$BAR" "$FOO"' '"$BAZ" "$BAR"' '"$BAR" "$BAZ"'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=52
 ACTUAL=0
 /bin/bash -c "$SCRIPT -eqv ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit 152
 fi
done

OPTION='-s'
echo "option: \"$OPTION\"..."

EXPECTED=21
ACTUAL=0
$SCRIPT $OPTION; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 121
fi

FILE="/tmp/file$(date +%s)"
echo "$(date +%s)" > "$FILE"
touch "${FILE}.empty"
[ ! -s "$FILE" ] && . ex/util/throw 101 "Illegal state!"
[ -s "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ ! -f "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ -f "${FILE}.not" ] && . ex/util/throw 101 "Illegal state!"

EXPECTED=111
ACTUAL=0
$SCRIPT $OPTION ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 121; fi

EXPECTED=112
ACTUAL=0
$SCRIPT $OPTION "$FILE" ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 121; fi

EXPECTED=113
ACTUAL=0
$SCRIPT $OPTION "$FILE" "$FILE" ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 121; fi

EXPECTED=121
ACTUAL=0
$SCRIPT $OPTION "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 122; fi

EXPECTED=122
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 122; fi

EXPECTED=122
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.not" "$FILE"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 122; fi

EXPECTED=131
ACTUAL=0
$SCRIPT $OPTION "${FILE}.empty"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 122; fi

EXPECTED=132
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.empty"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 123; fi

EXPECTED=132
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.empty" "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 123; fi

EXPECTED=121
ACTUAL=0
$SCRIPT $OPTION "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 122; fi

EXPECTED=122
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 123; fi

EXPECTED=122
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.not" "${FILE}.empty"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 123; fi

OPTION='-f'
echo "option: \"$OPTION\"..."

[ ! -s "$FILE" ] && . ex/util/throw 101 "Illegal state!"
[ -s "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ ! -f "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ -f "${FILE}.not" ] && . ex/util/throw 101 "Illegal state!"

EXPECTED=61
ACTUAL=0
$SCRIPT $OPTION; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 131; fi

EXPECTED=161
ACTUAL=0
$SCRIPT $OPTION ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 131; fi

EXPECTED=162
ACTUAL=0
$SCRIPT $OPTION "$FILE" ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 131; fi

EXPECTED=163
ACTUAL=0
$SCRIPT $OPTION "$FILE" "$FILE" ''; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 131; fi

EXPECTED=171
ACTUAL=0
$SCRIPT $OPTION "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 132; fi

EXPECTED=172
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 133; fi

EXPECTED=173
ACTUAL=0
$SCRIPT $OPTION "$FILE" "${FILE}.empty" "${FILE}.not"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 134; fi

echo "
Check success..."

# -d

DIR="/tmp/dir$(date +%s)"
rm -rf "$DIR"
mkdir -p "$DIR" || . ex/util/throw 101 "Illegal state!"
[ ! -d "$DIR" ] && . ex/util/throw 101 "Illegal state!"

QUERIES=("$DIR" "$DIR $DIR" "$DIR $DIR $DIR")
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=0
 ACTUAL=0
 $SCRIPT -d ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 151; fi
done

# -eq

QUERIES=('FOO BAZ' 'BAZ FOO' 'BAR2 BAR' 'BAR BAR2')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=0
 ACTUAL=0
 $SCRIPT -eq ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 152; fi
done

# -eqv

QUERIES=('"$FOO" "$BAZ"' '"$BAZ" "$FOO"' '"$BAR2" "$BAR"' '"$BAR" "$BAR2"')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=0
 ACTUAL=0
 /bin/bash -c "$SCRIPT -eqv ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 153; fi
done

[ ! -s "$FILE" ] && . ex/util/throw 101 "Illegal state!"
[ -s "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ ! -f "${FILE}.empty" ] && . ex/util/throw 101 "Illegal state!"
[ -f "${FILE}.not" ] && . ex/util/throw 101 "Illegal state!"

OPTION='-s'
echo "option: \"$OPTION\"..."

QUERIES=("$FILE" "$FILE $FILE" "$FILE $FILE $FILE")
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=0
 ACTUAL=0
 $SCRIPT $OPTION ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 154; fi
done

OPTION='-f'
echo "option: \"$OPTION\"..."

QUERIES=("$FILE" "$FILE ${FILE}.empty" "$FILE ${FILE}.empty $FILE" "$FILE ${FILE}.empty $FILE ${FILE}.empty")
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=0
 ACTUAL=0
 $SCRIPT $OPTION ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"; exit 155; fi
done
