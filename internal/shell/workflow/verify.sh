#!/bin/bash

echo 'Workflow verify'

repository/internal/shell/workflow/verify/service.sh
if test $? -ne 0; then
 repository/internal/shell/workflow/verify/service/on_failed.sh; exit 11; fi

repository/internal/unit/test/coverage.sh
if test $? -ne 0; then
 repository/internal/shell/workflow/verify/unit/test/coverage/on_failed.sh; exit 12; fi

internal/unit/test.sh
if test $? -ne 0; then
 repository/internal/shell/workflow/verify/unit/test/on_failed.sh; exit 13; fi

repository/internal/shell/workflow/verify/on_success.sh || exit 21
