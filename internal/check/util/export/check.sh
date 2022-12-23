#!/bin/bash

SCRIPT='ex/util/export'
. ex/util/assert -s "$SCRIPT"

echo '
Check error...'

$SCRIPT; . ex/util/assert -eqv $? 11
$SCRIPT '' 2; . ex/util/assert -eqv $? 101
$SCRIPT 1 ''; . ex/util/assert -eqv $? 121
$SCRIPT 'foo' ''; . ex/util/assert -eqv $? 102
$SCRIPT 'foo' 2; . ex/util/assert -eqv $? 122

echo '
Check success...'

[ -z "$FOO" ] || . ex/util/throw 101 'Illegal state!'
[ -z "$BAR" ] || . ex/util/throw 101 'Illegal state!'

rm /tmp/foo.sh
echo '[ -z "$FOO" ] && exit 111 || exit 0' > /tmp/foo.sh
chmod +x /tmp/foo.sh

rm /tmp/bar.sh
echo '[ -z "$BAR" ] && exit 112 || exit 0' > /tmp/bar.sh
chmod +x /tmp/bar.sh

/tmp/foo.sh; . ex/util/assert -eqv $? 111
/tmp/bar.sh; . ex/util/assert -eqv $? 112

FOO='foo'

/tmp/foo.sh; . ex/util/assert -eqv $? 111
/tmp/bar.sh; . ex/util/assert -eqv $? 112

. $SCRIPT FOO BAR

/tmp/foo.sh; . ex/util/assert -eqv $? 0
/tmp/bar.sh; . ex/util/assert -eqv $? 112

BAR='bar'

/tmp/foo.sh; . ex/util/assert -eqv $? 0
/tmp/bar.sh; . ex/util/assert -eqv $? 0

exit 0
