#!/bin/bash

SCRIPT='ex/util/throw'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

QUERIES=('"" ""' '"" 2' '1 ""')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT ${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 12
done

QUERIES=('a 2' 'foo 2' '- 2' '/ 2' '0 2' '-1 2')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 /bin/bash -c "$SCRIPT ${QUERIES[$QUERY_INDEX]}"; . ex/util/assert -eqv $? 31
done

echo "
Check success..."

QUERIES=(1 42 255)
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 EXPECTED=${QUERIES[$QUERY_INDEX]}
 $SCRIPT $EXPECTED 'foo'; . ex/util/assert -eqv $? $EXPECTED
done

exit 0
