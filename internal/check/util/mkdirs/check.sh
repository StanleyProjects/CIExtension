#!/bin/bash

echo "
Check error..."

EXPECTED=11
QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 ex/util/mkdirs ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20 + QUERY_INDEX))
 fi
done

EXPECTED=12
QUERIES=('""' \'\')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 /bin/bash -c "ex/util/mkdirs ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((30 + QUERY_INDEX))
 fi
done

EXPECTED=21
QUERIES=('/foo' '/1' '/-')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 /bin/bash -c "ex/util/mkdirs ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((40 + QUERY_INDEX))
 fi
done

echo "
Check success..."

QUERIES=('/' '/opt' '/tmp')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 DIR="${QUERIES[$QUERY_INDEX]}"
 if [ ! -d "$DIR" ]; then
  echo "Dir \"$DIR\" does not exist!"
  exit $((110 + QUERY_INDEX))
 fi
 . ex/util/mkdirs "$DIR"
 if [ ! -d "$DIR" ]; then
  echo "Dir \"$DIR\" does not exist!"
  exit $((120 + QUERY_INDEX))
 fi
done

QUERIES=("./$(date +%s)" "/tmp/$(date +%s)" "assemble/$(date +%s)")
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 DIR="${QUERIES[$QUERY_INDEX]}"
 if [ -d "$DIR" ]; then
  echo "Dir \"$DIR\" exists!"
  exit $((130 + QUERY_INDEX))
 fi
 . ex/util/mkdirs "$DIR"
 if [ ! -d "$DIR" ]; then
  echo "Dir \"$DIR\" does not exist!"
  exit $((140 + QUERY_INDEX))
 fi
done
