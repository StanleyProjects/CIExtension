#!/bin/bash

RELATIVE_PATH='internal/check/ex/github/assemble/actions/run/repository'
DOCKERFILE="$RELATIVE_PATH/Dockerfile"
NAME="$(md5sum <<< "$DOCKERFILE" | base64)"
NAME="${NAME,,}"
VERSION=$(date +"%Y%m%d%H")
TAG="$NAME:$VERSION"
CONTAINER="container.$NAME"

docker stop "$CONTAINER"
docker rm "$CONTAINER"

docker build --no-cache -f="$DOCKERFILE" -t="$TAG" .

if test $? -ne 0; then
 echo 'Build error!'; exit 21; fi

docker run --rm --name="$CONTAINER" "$TAG"

if test $? -ne 0; then
 echo 'Run error!'; exit 21; fi

docker rmi "$TAG"

exit 0
