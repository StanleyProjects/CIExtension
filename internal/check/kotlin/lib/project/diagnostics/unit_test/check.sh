#!/bin/bash

SCRIPT='ex/kotlin/lib/project/diagnostics/common.sh'
. ex/util/assert -s "$SCRIPT"

echo "
Check error..."

$SCRIPT; . ex/util/assert -eqv $? 11

$SCRIPT 'foo'; . ex/util/assert -eqv $? 152

REPOSITORY=repository
. ex/util/mkdirs "$REPOSITORY"

JSON_FILE="/tmp/$(date +%s)"
[ -f "$JSON_FILE" ] && . ex/util/throw 101 "File \"$JSON_FILE\" exists!"
$SCRIPT "$JSON_FILE"; . ex/util/assert -eqv $? 122

export VCS_DOMAIN='https://api.github.com'
export REPOSITORY_OWNER='kepocnhh'
export REPOSITORY_NAME='useless'

. ex/util/pipeline ex/github/assemble/repository.sh

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .clone_url REPOSITORY_CLONE_URL

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

GIT_BRANCH_SRC='eef05bd33d8a747011fd8435c64d965287ccb8fc' # snapshot

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

JSON_FILE="$JSON_PATH/verify/common.json"
. ex/util/assert -s "$JSON_FILE"
$SCRIPT "$JSON_FILE"; . ex/util/assert -eqv $? 122

echo "
Check success..."

QUERIES=(
 '328de7f9081ca90264abd06c132482e8b0498e26' 'common' '["CODE_STYLE"]'
 'bab0e659367d2b4de2cfb7e24c5e94e9663daec4' 'common' '["CODE_QUALITY_main","CODE_STYLE"]'
 'b3f9454b51368e18afbdc6ee20f3e03a8321cbff' 'common' '["CODE_QUALITY_main","CODE_QUALITY_test","CODE_STYLE"]'
 '009470e2d008f9487650bcfd29d8ee04a27405a2' 'info' '["README"]'
 'a8b0791820a4d22b80bb1a2d7e1ecc2182a26354' 'info' '["LICENSE","README"]'
 'ea5c3000794cad3a469b23b16343e7934a9bf176' 'documentation' '["DOCUMENTATION"]'
)
for ((QUERY_INDEX=0; QUERY_INDEX<$((${#QUERIES[@]} / 3)); QUERY_INDEX++)); do
 echo "check [$QUERY_INDEX/$((${#QUERIES[@]} / 3))]..."
 rm -rf "$REPOSITORY"
 . ex/util/mkdirs "$REPOSITORY"
 git -C "$REPOSITORY" init \
  && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
  && git -C "$REPOSITORY" fetch --depth=1 origin "${QUERIES[$((QUERY_INDEX * 3))]}" \
  && git -C "$REPOSITORY" checkout FETCH_HEAD \
  || . ex/util/throw 101 "Illegal state!"
 . ex/util/mkdirs diagnostics
 ARTIFACT=diagnostics/summary.json
 echo '{}' > "$ARTIFACT"
 JSON_FILE="$JSON_PATH/verify/${QUERIES[$((QUERY_INDEX * 3 + 1))]}.json"
 . ex/util/assert -s "$JSON_FILE"
 $SCRIPT "$JSON_FILE"; . ex/util/assert -eqv $? 0
 . ex/util/assert -eqv "$(jq -Mcer keys "$ARTIFACT")" "${QUERIES[$((QUERY_INDEX * 3 + 2))]}"
done

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"
git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin 'ea5c3000794cad3a469b23b16343e7934a9bf176' \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"
. ex/util/mkdirs diagnostics
ARTIFACT=diagnostics/summary.json
echo '{}' > "$ARTIFACT"
JSON_FILE="$JSON_PATH/verify/common.json"
. ex/util/assert -s "$JSON_FILE"
$SCRIPT \
 "$JSON_PATH/verify/common.json" \
 "$JSON_PATH/verify/info.json" \
 "$JSON_PATH/verify/documentation.json"; . ex/util/assert -eqv $? 0
. ex/util/assert -eqv "$(jq -Mcer keys "$ARTIFACT")" '["CODE_QUALITY_main","CODE_QUALITY_test","CODE_STYLE","DOCUMENTATION","LICENSE","README"]'

exit 0
