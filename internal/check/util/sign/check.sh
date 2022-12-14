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

rm "${FILE}.not"
[ -f "${FILE}.not" ] && . ex/util/throw 101 "Illegal state!"

KEY_FILE_NAME='/tmp/sign.check.key'
KEYSTORE_TYPE='pkcs12'
KEY_ALIAS='foo'

# 1

KEY_FILE="${KEY_FILE_NAME}.1"
rm "$KEY_FILE"
KEY_PASSWORD='password1'
KEY_CRT="${KEY_FILE}.crt"
rm "$KEY_CRT"
openssl req -newkey rsa:4096 -keyout "$KEY_FILE" -passout pass:"$KEY_PASSWORD" \
 -x509 -days 3650 -subj "/CN=$KEY_ALIAS" -out "$KEY_CRT"
. ex/util/assert -s "$KEY_FILE"
. ex/util/assert -s "$KEY_CRT"

KEYSTORE="${KEY_FILE}.$KEYSTORE_TYPE"
rm "$KEYSTORE"
openssl "$KEYSTORE_TYPE" \
 -passout pass:"$KEY_PASSWORD" -passin pass:"$KEY_PASSWORD" \
 -inkey "$KEY_FILE" \
 -in "$KEY_CRT" \
 -export -out "$KEYSTORE" -name "$KEY_ALIAS"
. ex/util/assert -s "$KEYSTORE"

openssl x509 -in <(openssl "$KEYSTORE_TYPE" -in "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" \
   -nokeys -passin pass:"$KEY_PASSWORD" | openssl x509) -checkend 0 \
 || . ex/util/throw 102 "Check error!"

rm "${FILE}1.sig"
openssl dgst -sha512 -sign <(openssl "$KEYSTORE_TYPE" -in "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" \
  -nocerts -passin pass:"$KEY_PASSWORD" -passout pass:"$KEY_PASSWORD") \
 -passin pass:"$KEY_PASSWORD" -out "${FILE}1.sig" "$FILE" \
 || . ex/util/throw 101 "Sign error!"

# 2

KEY_FILE="${KEY_FILE_NAME}.2"
rm "$KEY_FILE"
KEY_PASSWORD='password2'
KEY_CRT="${KEY_FILE}.crt"
rm "$KEY_CRT"
openssl req -newkey rsa:4096 -keyout "$KEY_FILE" -passout pass:"$KEY_PASSWORD" \
 -x509 -days 3650 -subj "/CN=$KEY_ALIAS" -out "$KEY_CRT"
. ex/util/assert -s "$KEY_FILE"
. ex/util/assert -s "$KEY_CRT"

KEYSTORE="${KEY_FILE}.$KEYSTORE_TYPE"
rm "$KEYSTORE"
openssl "$KEYSTORE_TYPE" \
 -passout pass:"$KEY_PASSWORD" -passin pass:"$KEY_PASSWORD" \
 -inkey "$KEY_FILE" \
 -in "$KEY_CRT" \
 -export -out "$KEYSTORE" -name "$KEY_ALIAS"
. ex/util/assert -s "$KEYSTORE"

openssl x509 -in <(openssl "$KEYSTORE_TYPE" -in "${KEY_FILE_NAME}.2.$KEYSTORE_TYPE" \
   -nokeys -passin pass:"$KEY_PASSWORD" | openssl x509) -checkend 0 \
 || . ex/util/throw 102 "Check error!"

rm "${FILE}2.sig"
openssl dgst -sha512 -sign <(openssl "$KEYSTORE_TYPE" -in "${KEY_FILE_NAME}.2.$KEYSTORE_TYPE" \
  -nocerts -passin pass:"$KEY_PASSWORD" -passout pass:"$KEY_PASSWORD") \
 -passin pass:"$KEY_PASSWORD" -out "${FILE}2.sig" "$FILE" \
 || . ex/util/throw 101 "Sign error!"

# todo expires

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

echo 'check expires...'
$SCRIPT -i "$FILE" -s 'foo' -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p 'bar'; . ex/util/assert -eqv $? 15
KEY_PASSWORD='password1'
echo 'check signature exists...'
$SCRIPT -i "$FILE" -s "${FILE}.empty" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p "$KEY_PASSWORD"; \
 . ex/util/assert -eqv $? 48
echo 'check password...'
$SCRIPT -i "$FILE" -e nocheck -s "${FILE}.not" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p 'foo'; \
 . ex/util/assert -eqv $? 251
rm "${FILE}.not"
$SCRIPT -i "$FILE" -t verify -s "${FILE}.not" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p "$KEY_PASSWORD"; \
 . ex/util/assert -eqv $? 49
$SCRIPT -i "$FILE" -t verify -s "${FILE}2.sig" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p "$KEY_PASSWORD"; \
 . ex/util/assert -eqv $? 252

echo "
Check success..."

KEY_PASSWORD='password1'
$SCRIPT -i "$FILE" -s "${FILE}.not" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p "$KEY_PASSWORD"; . ex/util/assert -eqv $? 0
rm "${FILE}.not"

rm "${FILE}.s1"
$SCRIPT -i "$FILE" -s "${FILE}.s1" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p "$KEY_PASSWORD"; . ex/util/assert -eqv $? 0
. ex/util/assert -s "$FILE"
openssl dgst -sha512 -verify <(openssl "$KEYSTORE_TYPE" -in "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" \
  -nokeys -passin pass:"$KEY_PASSWORD" | openssl x509 -pubkey -noout) \
 -signature "${FILE}.s1" "$FILE" \
 || . ex/util/throw 101 "Sign error!"

$SCRIPT -i "$FILE" -t verify -s "${FILE}1.sig" -k "${KEY_FILE_NAME}.1.$KEYSTORE_TYPE" -p "$KEY_PASSWORD"; . ex/util/assert -eqv $? 0

exit 0
