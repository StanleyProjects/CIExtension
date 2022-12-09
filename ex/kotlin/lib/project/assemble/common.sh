#!/bin/bash

echo "Project assemble common..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

gradle -q -p "$REPOSITORY" saveCommonInfo \
 || . ex/util/throw 11 "Save common info error!"

ARTIFACT="$REPOSITORY/build/common.json"
. ex/util/assert -s "$ARTIFACT"
. ex/util/mkdirs assemble/project
cp "$ARTIFACT" assemble/project/common.json

. ex/util/json -f assemble/project/common.json \
 -sfs .repository.owner ACTUAL_OWNER \
 -sfs .repository.name ACTUAL_NAME

. ex/util/json -f assemble/vcs/repository.json \
 -sfs .owner.login REPOSITORY_OWNER_LOGIN \
 -sfs .name REPOSITORY_NAME

. ex/util/assert -eq ACTUAL_OWNER REPOSITORY_OWNER_LOGIN
. ex/util/assert -eq ACTUAL_NAME REPOSITORY_NAME
