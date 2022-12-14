#!/bin/bash

SCRIPT='ex/util/sign'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

FILE="/tmp/sign.check.txt"
rm "$FILE"
echo "date $(date +%s)" > "$FILE"

. ex/util/assert -s "$FILE"

rm "${FILE}.empty"
touch "${FILE}.empty"

KEY_FILE="/tmp/sign.check.key"
rm "$KEY_FILE"
KEY_PASSWORD="$(date +%s)"
KEY_ALIAS='foo'
KEY_CRT="/tmp/sign.check.crt"
rm "$KEY_CRT"
openssl req -newkey rsa:4096 -keyout "$KEY_FILE" -passout pass:"$KEY_PASSWORD" \
 -x509 -days 3650 -subj "/CN=$KEY_ALIAS" -out "$KEY_CRT"
. ex/util/assert -s "$KEY_FILE"
. ex/util/assert -s "$KEY_CRT"

KEYSTORE_TYPE='pkcs12'
KEYSTORE="/tmp/sign.check.$KEYSTORE_TYPE"
rm "$KEYSTORE"
openssl "$KEYSTORE_TYPE" \
 -passout pass:"$KEY_PASSWORD" -passin pass:"$KEY_PASSWORD" \
 -inkey "$KEY_FILE" \
 -in "$KEY_CRT" \
 -export -out "$KEYSTORE" -name "$KEY_ALIAS"
. ex/util/assert -s "$KEYSTORE"

echo "
Check arguments..."

QUERIES=(
 ''
 '1'
 '1 2'
 '1 2 3'
 '1 2 3 4'
 '1 2 3 4 5 6 7'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=(
 '9'
 '9 10 11'
 '9 10 11 12 13'
)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT 1 2 3 4 5 6 7 8 ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 12
done

$SCRIPT -a 'a1' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 41
$SCRIPT -t 'a1' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 42
$SCRIPT -t 'a1' -p 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 43

$SCRIPT -k "$FILE" -k 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 52
$SCRIPT -k '' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 61
$SCRIPT -k "${FILE}.not" -k 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 71
$SCRIPT -k "${FILE}.empty" -k 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 71

$SCRIPT -i "$FILE" -i 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 82
$SCRIPT -i '' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 91
$SCRIPT -i "${FILE}.not" -i 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 101
$SCRIPT -i "${FILE}.empty" -i 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 101

$SCRIPT -t 'a1' -t 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 112
$SCRIPT -t '' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 121

$SCRIPT -s 'a1' -s 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 132
$SCRIPT -s '' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 141

$SCRIPT -p 'a1' -p 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 152
$SCRIPT -p '' -a 'a2' -a 'a3' -a 'a4' -a 'a5' -a 'a6' -a 'a7' -a 'a8'; . ex/util/assert -eqv $? 161

echo "Not implemented!"; exit 1 # todo

echo "
Check success..."

echo "Not implemented!"; exit 1 # todo

exit 0
