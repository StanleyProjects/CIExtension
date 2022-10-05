#!/bin/bash

echo "
Check error..."

EXPECTED=11
QUERIES=('' '1' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 ex/util/url ${QUERIES[$QUERY_INDEX]}; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((20 + QUERY_INDEX))
 fi
done

EXPECTED=12
QUERIES=('"" ""' '"" 2' '1 ""')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 ACTUAL=0
 /bin/bash -c "ex/util/url ${QUERIES[$QUERY_INDEX]}"; ACTUAL=$?
 if test $ACTUAL -ne $EXPECTED; then
  echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
  exit $((30 + QUERY_INDEX))
 fi
done

EXPECTED=21
ACTUAL=0
ex/util/url 1 '/'; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 41
fi

EXPECTED=22
ACTUAL=0
ex/util/url 1 2; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 42
fi

echo "
Check success..."

REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
OUTPUT="/tmp/$(date +%s)"
if test -f "OUTPUT"; then
 echo "Destination \"$OUTPUT\" exists!"
 exit 101
fi
EXPECTED=0
ACTUAL=0
ex/util/url "https://api.github.com/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME" "$OUTPUT"; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 51
fi

if [ ! -s "$OUTPUT" ]; then
 echo "Destination does not exist!"
 exit 21
fi

if test "$(jq -r .name "$OUTPUT")" != "$REPOSITORY_NAME"; then
 echo "Actual repository name error!"
 exit 31
fi

if test "$(jq -r .owner.login "$OUTPUT")" != "$REPOSITORY_OWNER"; then
 echo "Actual repository owner login error!"
 exit 32
fi
