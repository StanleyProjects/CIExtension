#!/bin/bash

if test -z "$FOO"; then
 echo "Value is empty!"; exit 21
fi

if [ ! -z "$BAR" ]; then
 echo "Value does not empty!"; exit 22
fi
