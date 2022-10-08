#!/bin/bash

echo "Workflow verify check..."

REPOSITORY=repository
. ex/util/assert -d "$REPOSITORY"

ex/kotlin/lib/project/verify/pre.sh \
 || . ex/util/throw 11 "Pre verify unexpected error!"

JSON_PATH="$REPOSITORY/buildSrc/src/main/resources/json"
ex/kotlin/lib/project/verify/common.sh \
 "$JSON_PATH/verify/common.json" \
 && ex/kotlin/lib/project/verify/unit_test.sh && exit 0

. ex/util/mkdirs diagnostics
echo "{}" > diagnostics/summary.json
ex/kotlin/lib/project/diagnostics/common.sh \
 "$JSON_PATH/verify/common.json" \
 && ex/kotlin/lib/project/diagnostics/unit_test.sh \
 && ex/github/diagnostics/report.sh \
 || . ex/util/throw 21 "Diagnostics unexpected error!"

ci/workflow/verify/on_failed.sh \
 || . ex/util/throw 22 "On failed unexpected error!"

exit 31
