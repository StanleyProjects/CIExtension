#!/bin/bash

# VERSION=$(date +%s) # todo
VERSION=1

docker build \
 -f=internal/check/util/foo/foo.docker \
 -t=ci.extension.util.foo:$VERSION .
