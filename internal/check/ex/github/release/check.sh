#!/bin/bash

SCRIPT='ex/github/release.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

QUERIES=('' '1 2' '1 2 3')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 $SCRIPT ${QUERIES[$QUERY_INDEX]}; . ex/util/assert -eqv $? 11
done

$SCRIPT ''; . ex/util/assert -eqv $? 101

CHECK_BODY='{}'
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 102
export VCS_PAT="$CHECK_VCS_PAT"
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 41
QUERIES=('false' 'true' '42' '[]' '{}' '""')
for ((QUERY_INDEX=0; QUERY_INDEX<${#QUERIES[@]}; QUERY_INDEX++)); do
 . ex/util/json_merge -v CHECK_BODY ".name=${QUERIES[$QUERY_INDEX]}"
 $SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 41
done

CHECK_RELEASE_NAME="release/$(date +%s)"
. ex/util/json_merge -v CHECK_BODY \
 ".name=\"$CHECK_RELEASE_NAME\""
[ -f assemble/vcs/repository.json ] && . ex/util/throw 101 "Illegal state!"
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 122

[ -d assemble/vcs ] && . ex/util/throw 101 "Illegal state!"
. ex/util/mkdirs assemble/vcs
echo '{}' > assemble/vcs/repository.json
VCS_DOMAIN='https://api.github.com'
REPOSITORY_OWNER='StanleyProjects'
REPOSITORY_NAME='CIExtension'
. ex/util/json_merge -f assemble/vcs/repository.json \
 ".url=\"$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME\""
. ex/util/assert -s assemble/vcs/repository.json
$SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 21

echo "
Check success..."

export VCS_DOMAIN='https://api.github.com'
. ex/util/pipeline ex/github/assemble/worker.sh

QUERIES=(
 '1d19078f472b531b0263bdc6a95983bb6dc8ff9b' 'false' 'false'
 'b73b2ece6cc02e09b894590a93d96d31a413a555' 'false' 'true'
 '68806b78698558d685024804dc37de546981be44' 'true' 'false'
 '538b3f463ca5395c125b1616f4b30452f31cc0dc' 'true' 'true'
)
QUERIES_SIZE=${#QUERIES[@]}
for ((QUERY_INDEX=0; QUERY_INDEX<$((QUERIES_SIZE / 3)); QUERY_INDEX++)); do
 CHECK_COMMIT_SHA="${QUERIES[$((QUERY_INDEX * 3 + 0))]}"
 . ex/util/require CHECK_COMMIT_SHA
 CHECK_COMMIT_SHA_SHORT="$(echo "$CHECK_COMMIT_SHA" | cut -b-7)"
 CHECK_RELEASE_NAME="release/$CHECK_COMMIT_SHA_SHORT/$(date +%s)"
 CHECK_MESSAGE="message/$CHECK_COMMIT_SHA_SHORT/$(date +%s)"
 CHECK_TAG_NAME="tag/name/$CHECK_COMMIT_SHA_SHORT/$(date +%s)"
 CHECK_DRAFT="${QUERIES[$((QUERY_INDEX * 3 + 1))]}"
 CHECK_PRERELEASE="${QUERIES[$((QUERY_INDEX * 3 + 2))]}"
 echo "$((QUERY_INDEX + 1))/$((QUERIES_SIZE / 3))] $CHECK_RELEASE_NAME $CHECK_TAG_NAME d: $CHECK_DRAFT p: $CHECK_PRERELEASE"
 CHECK_BODY='{}'
 . ex/util/json_merge -v CHECK_BODY \
  ".name=\"$CHECK_RELEASE_NAME\"" \
  ".target_commitish=\"$CHECK_COMMIT_SHA\"" \
  ".tag_name=\"$CHECK_TAG_NAME\"" \
  ".body=\"$CHECK_MESSAGE\"" \
  ".draft=$CHECK_DRAFT" \
  ".prerelease=$CHECK_PRERELEASE"
 rm assemble/github/release.json
 [ -f assemble/github/release.json ] && . ex/util/throw 101 "Illegal state!"
 $SCRIPT "$CHECK_BODY"; . ex/util/assert -eqv $? 0
 . ex/util/assert -s assemble/github/release.json
 . ex/util/assert -eqv "$(jq -Mcr .name assemble/github/release.json)" "$CHECK_RELEASE_NAME"
 . ex/util/assert -eqv "$(jq -Mcr .tag_name assemble/github/release.json)" "$CHECK_TAG_NAME"
 . ex/util/assert -eqv "$(jq -Mcr .target_commitish assemble/github/release.json)" "$CHECK_COMMIT_SHA"
 . ex/util/assert -eqv "$(jq -Mcr .body assemble/github/release.json)" "$CHECK_MESSAGE"
 . ex/util/assert -eqv "$(jq -Mc .draft assemble/github/release.json)" "$CHECK_DRAFT"
 . ex/util/assert -eqv "$(jq -Mc .prerelease assemble/github/release.json)" "$CHECK_PRERELEASE"
 . ex/util/assert -eqv "$(jq -Mcr .author.login assemble/github/release.json)" "$(jq -Mcr .login assemble/vcs/worker.json)"
 . ex/util/assert -eqv "$(jq -Mc .author.id assemble/github/release.json)" "$(jq -Mc .id assemble/vcs/worker.json)"
done

exit 0
