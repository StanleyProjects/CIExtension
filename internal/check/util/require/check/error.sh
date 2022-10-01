#!/bin/bash

export FOO='foo'
export BAR=''

if test -z "$FOO"; then
 echo "Value is empty!"; exit 11
fi

if [ ! -z "$BAR" ]; then
 echo "Value does not empty!"; exit 12
fi

EXPECTED=11
ACTUAL=0
ex/util/require; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 21
fi

EXPECTED=101
ACTUAL=0
ex/util/require BAR; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 31
fi

EXPECTED=102
ACTUAL=0
ex/util/require FOO BAR; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 32
fi

if [ ! -z "$BAZ" ]; then
 echo "Value does not empty!"; exit 13
fi

EXPECTED=103
ACTUAL=0
ex/util/require FOO FOO BAZ; ACTUAL=$?
if test $ACTUAL -ne $EXPECTED; then
 echo "Actual code is \"$ACTUAL\", but expected is \"$EXPECTED\"!"
 exit 33
fi
