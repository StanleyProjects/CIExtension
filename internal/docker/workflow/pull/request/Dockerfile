from kepocnhh/debian-amd64:4

run mkdir -p /prepare/repository
workdir /prepare/repository

arg VCS_PAT
arg REPOSITORY_OWNER
arg REPOSITORY_NAME
arg GIT_BRANCH_SRC

run [ ! -z "$VCS_PAT" ]
run [ ! -z "$REPOSITORY_OWNER" ]
run [ ! -z "$REPOSITORY_NAME" ]
run [ ! -z "$GIT_BRANCH_SRC" ]

run git init
run git remote add origin "https://${VCS_PAT}@github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}.git"
run git fetch origin "$GIT_BRANCH_SRC"
run git checkout FETCH_HEAD

workdir /prepare

run mkdir ex
run cp -r repository/ex/util ex/util

arg VCS_DOMAIN
arg PR_NUMBER
arg CI_BUILD_ID

run [ ! -z "$VCS_DOMAIN" ]
run [ ! -z "$PR_NUMBER" ]
run [ ! -z "$CI_BUILD_ID" ]

run repository/internal/shell/workflow/pull/request/prepare/merge.sh

workdir /workdir

run mv /prepare/repository repository
run rm -rf /prepare
run cp -r repository/ex ex

run repository/internal/shell/workflow/pull/request/setup.sh
