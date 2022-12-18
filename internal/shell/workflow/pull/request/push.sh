#!/bin/bash

echo 'Workflow pull request push'

ex/github/workflow/pr/commit.sh \
 && git -C repository push \
 && ex/github/assemble/commit.sh \
 || . ex/util/throw 21 'Illegal state!'
