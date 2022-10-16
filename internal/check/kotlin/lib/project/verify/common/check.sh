#!/bin/bash

SCRIPT='ex/kotlin/lib/project/verify/common.sh'
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

GIT_BRANCH_SRC='f41e7ff3a2a066f21ebbe94f0a6adfe5031dd838'

rm -rf "$REPOSITORY"
. ex/util/mkdirs "$REPOSITORY"

git -C "$REPOSITORY" init \
 && git -C "$REPOSITORY" remote add origin "$REPOSITORY_CLONE_URL" \
 && git -C "$REPOSITORY" fetch --depth=1 origin "$GIT_BRANCH_SRC" \
 && git -C "$REPOSITORY" checkout FETCH_HEAD \
 || . ex/util/throw 101 "Illegal state!"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
. ex/util/assert -d "$JSON_PATH"
JSON_FILE="$JSON_PATH/verify/common.json"
. ex/util/assert -s "$JSON_FILE"

echo 'foo' > "${JSON_FILE}.broken"
$SCRIPT "${JSON_FILE}.broken"; . ex/util/assert -eqv $? 201
echo '{}' > "${JSON_FILE}.broken"
$SCRIPT "${JSON_FILE}.broken"; . ex/util/assert -eqv $? 201
echo '{"FOO": {}}' > "${JSON_FILE}.broken"
$SCRIPT "${JSON_FILE}.broken"; . ex/util/assert -eqv $? 42
echo '{"FOO": {"task":"bar"}}' > "${JSON_FILE}.broken"
$SCRIPT "${JSON_FILE}.broken"; . ex/util/assert -eqv $? 42

KEY_NAME='CLEAN'
TASK_NAME='clean'
echo "{
 \"$KEY_NAME\": {
  \"title\": \"title\",
  \"task\": \"$TASK_NAME\"
 }
}" > "${JSON_FILE}.success"
. ex/util/assert -s "${JSON_FILE}.success"
gradle -p "$REPOSITORY" "$(jq -Mcer ".${KEY_NAME}.task" "${JSON_FILE}.success")" \
 || . ex/util/throw 101 "Gradle error!"

[ -f "${JSON_FILE}.not" ] && . ex/util/throw 101 "File \"${JSON_FILE}.not\" exists!"

$SCRIPT "${JSON_FILE}.not" "${JSON_FILE}.success"; . ex/util/assert -eqv $? 122
$SCRIPT "${JSON_FILE}.success" "${JSON_FILE}.not"; . ex/util/assert -eqv $? 122
gradle -p "$REPOSITORY" "$(jq -Mcer '.CODE_STYLE.task' "$JSON_FILE")" \
 && . ex/util/throw 101 "Gradle success!"
$SCRIPT "$JSON_FILE"; . ex/util/assert -eqv $? 113
$SCRIPT "${JSON_FILE}.success" "$JSON_FILE"; . ex/util/assert -eqv $? 123

echo "
Check success..."

. $SCRIPT "${JSON_FILE}.success"

exit 0
