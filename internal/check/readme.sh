#!/bin/bash

[ ! -z "$VERSION" ] && . ex/util/throw 101 "Illegal state!"
. ex/util/assert -s .github/env
. .github/env
. ex/util/require VERSION

ISSUER='README.md'
. ex/util/assert -s "$ISSUER"
LINE_EXPECTED="![version](https://img.shields.io/static/v1?label=version&message=${VERSION}&labelColor=212121&color=2962ff&style=flat)"
[ "$(cat "$ISSUER")" != "$LINE_EXPECTED"* ] \
 && . ex/util/throw 21 "File \"$ISSUER\" does not start with \"$LINE_EXPECTED\"!"
