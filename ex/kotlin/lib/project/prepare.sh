#!/bin/bash

echo "Project prepare..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

echo "Clean..."
gradle -p "$REPOSITORY" clean \
 || . ex/util/throw 11 "Gradle clean error!"

echo "Compile..."
gradle -p "$REPOSITORY" lib:compileKotlin \
 || . ex/util/throw 12 "Gradle compile error!"
