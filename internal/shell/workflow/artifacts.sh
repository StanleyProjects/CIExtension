#!/bin/bash

echo 'Workflow artifacts'

if test $# -ne 1; then
 echo "Script needs for 1 argument, but actual is $#!"; exit 11; fi

TAG="$1"

. ex/util/require TAG KEYSTORE KEYSTORE_PASSWORD KEY_X509_SHA512

mkdir -p assemble/project/artifact
ARTIFACT="CIExtension-${TAG}.zip"
$(ISSUER="$(pwd)" && cd "${ISSUER}/repository" && zip -r9 "${ISSUER}/assemble/project/artifact/$ARTIFACT" ci ex > /dev/null)

echo "$KEYSTORE" | base64 -d > 'assemble/project/keystore.pkcs12'

ex/util/sign \
 -i "assemble/project/artifact/$ARTIFACT" \
 -s "assemble/project/artifact/${ARTIFACT}.sig" \
 -k 'assemble/project/keystore.pkcs12' \
 -p "$KEYSTORE_PASSWORD" || exit 1 # todo

ACTUAL_FINGERPRINT="$(\
 openssl pkcs12 \
  -in 'assemble/project/keystore.pkcs12' \
  -nokeys -passin "pass:$KEYSTORE_PASSWORD" \
  | openssl x509 -noout -fingerprint -sha512 \
)"

EXPECTED_FINGERPRINT="SHA512 Fingerprint=$KEY_X509_SHA512"

. ex/util/require ACTUAL_FINGERPRINT EXPECTED_FINGERPRINT
. ex/util/assert -eqv "${ACTUAL_FINGERPRINT^^}" "${EXPECTED_FINGERPRINT^^}"
