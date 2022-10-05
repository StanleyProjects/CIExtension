#!/bin/bash

FOO='foo'
BAR='bar'

if test -z "$FOO"; then
 echo "Value is empty!"; exit 11
fi

if test -z "$BAR"; then
 echo "Value is empty!"; exit 12
fi

. ex/util/require FOO
. ex/util/require FOO BAR
. ex/util/require BAR
