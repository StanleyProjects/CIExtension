#!/bin/bash

RELATIVE_PATH='internal/check/github/assemble/pr/commit'
DOCKERFILE="$RELATIVE_PATH/Dockerfile"
NAME="$(md5sum <<< "$RELATIVE_PATH" | base64)"
NAME="${NAME,,}"
VERSION=$(date +"%Y%m%d%H")
TAG="$NAME:$VERSION"
CONTAINER="container.$NAME"

docker stop "$CONTAINER"
docker rm "$CONTAINER"

CODE=0
docker build --no-cache -f="$DOCKERFILE" -t="$TAG" . \
 && docker run --rm --name="$CONTAINER" "$TAG"; CODE=$?

if test $CODE -ne 0; then
 echo "Build error!"
 exit 21
fi

docker rmi "$TAG"

exit 0
