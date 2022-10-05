#!/bin/bash

FILE='sample.json'

if [ ! -s "$FILE" ]; then
 echo "The file \"$FILE\" does not exist!"; exit 11
fi

SOURCE="$(cat "$FILE")"

if test -z "$SOURCE"; then
 echo "The source is empty!"; exit 12
fi

rm "${FILE}.empty"
touch "${FILE}.empty"

if [ ! -f "${FILE}.empty" ]; then
 echo "The file \"${FILE}.empty\" does not exist!"; exit 16
elif test -s "${FILE}.empty"; then
 echo "The file \"${FILE}.empty\" does not empty!"; exit 17
fi

if test -s "${FILE}.not"; then
 echo "The file \"${FILE}.not\" exists!"; exit 19
fi

echo "
Check arguments..."

EXPECTED=11
ARRAY=(
 ''
 '1'
 '1 2'
 '1 2 3'
 '1 2 3 4'
)
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json ${ARRAY[$i]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20+i))
 fi
done

EXPECTED=12
ARRAY=(
 '1'
 '1 2'
 '1 2 3 1'
 '1 2 3 1 2'
)
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json o s 1 2 3 ${ARRAY[$i]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((30+i))
 fi
done

echo "
Check source options..."

EXPECTED=13
ARRAY=('' 'a' '-a' 'foo' '1')
for ((i=0; i<${#ARRAY[@]}; i++)); do
 ACTUAL=0
 ex/util/json "${ARRAY[$i]}" s 1 2 3; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((40+i))
 fi
done

echo "
Check sources..."

EXPECTED=121
ACTUAL=0
ex/util/json -j '' 1 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 51
fi

EXPECTED=122
ACTUAL=0
ex/util/json -f "${FILE}.not" 1 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 52
fi

EXPECTED=123
ACTUAL=0
ex/util/json -f "${FILE}.empty" 1 2 3; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 53
fi

SOURCES=(
 '-f' "$FILE"
 '-j' "$SOURCE"
)
for ((SOURCE_INDEX=0; SOURCE_INDEX<$((${#SOURCES[@]} / 2)); SOURCE_INDEX++)); do
 SOURCE_OPTION="${SOURCES[$((SOURCE_INDEX * 2 + 0))]}"
 SOURCE="${SOURCES[$((SOURCE_INDEX * 2 + 1))]}"

 echo "Source option: $SOURCE_OPTION"

 echo "
 Check query options..."

 EXPECTED=21
 QUERIES=('a' '-a' 'foo' '1')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" ${QUERIES[$QUERY_INDEX]} 2 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 110 + QUERY_INDEX))
  fi
 done

 echo "
 Check queries..."

 QUERIES=('-si a' '-sfs -a' '-sb foo')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  case "$SOURCE_OPTION" in
   '-j') EXPECTED=41;;
   '-f') EXPECTED=42;;
   *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
  esac
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" ${QUERIES[$QUERY_INDEX]} 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 120 + QUERY_INDEX))
  fi
 done
 QUERIES=(
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_string'
  '.val_string_empty'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  case "$SOURCE_OPTION" in
   '-j') EXPECTED=41;;
   '-f') EXPECTED=42;;
   *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
  esac
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" -si "${QUERIES[$QUERY_INDEX]}" 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 130 + QUERY_INDEX))
  fi
 done
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_string_empty'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  case "$SOURCE_OPTION" in
   '-j') EXPECTED=41;;
   '-f') EXPECTED=42;;
   *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
  esac
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" -sfs "${QUERIES[$QUERY_INDEX]}" 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 140 + QUERY_INDEX))
  fi
 done
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_boolean_true'
  '.val_boolean_false'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  case "$SOURCE_OPTION" in
   '-j') EXPECTED=41;;
   '-f') EXPECTED=42;;
   *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
  esac
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" -ss "${QUERIES[$QUERY_INDEX]}" 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 150 + QUERY_INDEX))
  fi
 done
 QUERIES=(
  '.val_int'
  '.val_float'
  '.val_string'
  '.val_string_empty'
  '.val_object'
  '.val_array_2'
  '.val_array_empty'
  '.val_null'
 )
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  case "$SOURCE_OPTION" in
   '-j') EXPECTED=41;;
   '-f') EXPECTED=42;;
   *) echo "Source option \"$SOURCE_OPTION\" is not supported!"; exit 21;;
  esac
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" -sb "${QUERIES[$QUERY_INDEX]}" 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 160 + QUERY_INDEX))
  fi
 done

 echo "
 Check query errors..."

 QUERIES=('' '-si .val_int VAL_INT')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  EXPECTED=101
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" ${QUERIES[$QUERY_INDEX]} '' 2 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 610 + QUERY_INDEX))
  fi
  EXPECTED=102
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" ${QUERIES[$QUERY_INDEX]} -si '' 3; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 620 + QUERY_INDEX))
  fi
  EXPECTED=103
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" ${QUERIES[$QUERY_INDEX]} -si 2 ''; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 630 + QUERY_INDEX))
  fi
 done

 EXPECTED=104
 QUERIES=('1' '2' '42' '-a' '/foo')
 for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
  ACTUAL=0
  ex/util/json "$SOURCE_OPTION" "$SOURCE" -si .val_int "${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
  if test $ACTUAL -ne $EXPECTED; then
   echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
   exit $((1000 * SOURCE_INDEX + 210 + QUERY_INDEX))
  fi
 done
done
