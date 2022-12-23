#!/bin/bash

echo 'Workflow verify'

repository/internal/unit/test/coverage.sh
if test $? -ne 0; then
 repository/internal/shell/workflow/verify/unit/test/coverage/on_failed.sh; exit 11; fi

internal/unit/test.sh
if test $? -ne 0; then
 repository/internal/shell/workflow/verify/unit/test/on_failed.sh; exit 12; fi

repository/internal/shell/workflow/verify/on_success.sh || exit 13
