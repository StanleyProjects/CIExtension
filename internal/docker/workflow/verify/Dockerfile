from kepocnhh/docker-amd64:2

run mkdir -p /workdir/repository
workdir /workdir/repository

arg VCS_PAT
arg REPOSITORY_OWNER
arg REPOSITORY_NAME
arg GIT_BRANCH_SRC

run [ ! -z "$REPOSITORY_OWNER" ]
run [ ! -z "$REPOSITORY_NAME" ]
run [ ! -z "$GIT_BRANCH_SRC" ]

run git init
run git remote add origin "https://github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}.git"
run git fetch origin "$GIT_BRANCH_SRC"
run git checkout FETCH_HEAD

workdir /workdir

run [ ! -z "$VCS_PAT" ]
run [ ! -z "$TELEGRAM_BOT_ID" ]
run [ ! -z "$TELEGRAM_BOT_TOKEN" ]
run [ ! -z "$TELEGRAM_CHAT_ID" ]

run repository/internal/shell/workflow/verify/setup.sh

cmd /usr/local/bin/run_docker_daemon.sh \
 && repository/internal/shell/workflow/verify.sh
