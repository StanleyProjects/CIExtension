#!/bin/bash

SCRIPT='ex/util/require'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

export FOO='foo'
export BAR=''

[ -z "$FOO" ] && . ex/util/throw 101 "Illegal state!"
[ ! -z "$BAR" ] && . ex/util/throw 101 "Illegal state!"

$SCRIPT; . ex/util/assert -eqv $? 11

$SCRIPT BAR; . ex/util/assert -eqv $? 101

$SCRIPT FOO BAR; . ex/util/assert -eqv $? 102

[ ! -z "$BAZ" ] && . ex/util/throw 101 "Illegal state!"

$SCRIPT FOO FOO BAZ; . ex/util/assert -eqv $? 103

echo "
Check success..."

BAR='bar'
[ -z "$FOO" ] && . ex/util/throw 101 "Illegal state!"
[ -z "$BAR" ] && . ex/util/throw 101 "Illegal state!"

. ex/util/require FOO
. ex/util/require FOO BAR
. ex/util/require BAR

exit 0
