#!/bin/bash

echo "Workflow verify project prepare..."

. ex/util/pipeline \
 ex/kotlin/lib/project/prepare.sh \
 ex/kotlin/lib/project/assemble/common.sh
