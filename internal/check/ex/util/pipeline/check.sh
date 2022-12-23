#!/bin/bash

SCRIPT='ex/util/pipeline'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 11
$SCRIPT '' 2; . ex/util/assert -eqv $? 21
$SCRIPT 'echo 1' ''; . ex/util/assert -eqv $? 22

QUERIES=(
 'exit 1'
 'foo'
 '1'
 '/bin/false'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT "${QUERIES[$QUERY_INDEX]}" 'echo 2'; . ex/util/assert -eqv $? 31
 $SCRIPT 'echo 1' "${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 32
done

echo "
Check success..."

export FOO='foo'
export BAR=''

. ex/util/require FOO
[ ! -z "$BAR"] && . ex/util/throw 101 "Illegal state!"

ARTIFACT='/tmp/test.sh'
echo '
if test -z "$FOO"; then
 echo "Value is empty!"; exit 21
fi

if [ ! -z "$BAR" ]; then
 echo "Value does not empty!"; exit 22
fi
' > "$ARTIFACT"
. ex/util/assert -s "$ARTIFACT"
chmod +x "$ARTIFACT" || . ex/util/throw 101 "Illegal state!"
$SCRIPT "$ARTIFACT"; . ex/util/assert -eqv $? 0

$SCRIPT \
 'exit 0' \
 'echo 1' \
 'echo 2' \
 'echo 3'; . ex/util/assert -eqv $? 0

$SCRIPT \
 'exit 0' \
 'echo a' \
 'echo b' \
 'echo c'; . ex/util/assert -eqv $? 0

exit 0
