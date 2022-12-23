#!/bin/bash

echo 'Workflow verify'

internal/shell/workflow/verify/service.sh
if test $? -ne 0; then
 internal/shell/workflow/verify/service/on_failed.sh; exit 11; fi

internal/unit/test/coverage.sh
if test $? -ne 0; then
 internal/shell/workflow/verify/unit/test/coverage/on_failed.sh; exit 12; fi

internal/unit/test.sh
if test $? -ne 0; then
 internal/shell/workflow/verify/unit/test/on_failed.sh; exit 13; fi

internal/shell/workflow/verify/on_success.sh || exit 21
