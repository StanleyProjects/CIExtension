#!/bin/bash

DOCKERFILE="internal/check/util/json/Dockerfile"
NAME="$(md5sum <<< "$DOCKERFILE" | base64)"
NAME="${NAME,,}"
VERSION=$(date +%s)
TAG="$NAME:$VERSION"
CONTAINER="container.$NAME"

docker stop "$CONTAINER"
docker rm "$CONTAINER"

CODE=0
docker build --no-cache -f="$DOCKERFILE" -t="$TAG" . \
 && docker run -td --name="$CONTAINER" "$TAG" \
 && docker exec "$CONTAINER" check/success.sh \
 && docker exec "$CONTAINER" check/error.sh; CODE=$?

if test $CODE -ne 0; then
 echo "Build error!"
 exit 21
fi

docker stop "$CONTAINER"
docker rm "$CONTAINER"
docker rmi "$TAG"

exit 0
