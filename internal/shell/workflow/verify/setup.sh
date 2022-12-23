#!/bin/bash

echo 'Workflow verify setup'

. ex/util/require VCS_PAT TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID

ENVS=(
 github/assemble/repository/pages
 github/assemble/worker
 github/diagnostics/report
 github/release
)
for it in "${ENVS[@]}"; do \
 . ex/util/assert -d "repository/internal/check/ex/$it"
 ISSUE="repository/internal/check/ex/$it/env"
 echo "CHECK_VCS_PAT=$VCS_PAT" >> "$ISSUE" \
 || . ex/util/throw 11 "Script \"$it\" error!"; done

TELEGRAMS=(
 notification/telegram/send_message
 notification/telegram/send_file
)
for it in "${TELEGRAMS[@]}"; do \
 . ex/util/assert -d "repository/internal/check/ex/$it"
 ISSUE="repository/internal/check/ex/$it/env"
 echo "CHECK_TELEGRAM_BOT_ID=$TELEGRAM_BOT_ID" >> "$ISSUE" && \
 echo "CHECK_TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN" >> "$ISSUE" && \
 echo "CHECK_TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID" >> "$ISSUE" \
 || . ex/util/throw 12 "Script \"$it\" error!"; done
