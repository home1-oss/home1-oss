#!/usr/bin/env bash







export BUILD_PUBLISH_DEPLOY_SEGREGATION="false"
export BUILD_SITE_PATH_PREFIX="oss"
export BUILD_SKIP_COMMANDS_EXECUTION="true"

source src/main/resources/oss_repositories.sh
source src/gitbook/book.sh

### OSS CI CALL REMOTE CI SCRIPT BEGIN
if [ -z "${LIB_CI_SCRIPT}" ]; then LIB_CI_SCRIPT="https://github.com/home1-oss/oss-build/raw/master/src/main/ci-script/lib_ci.sh"; fi
#if [ -z "${LIB_CI_SCRIPT}" ]; then LIB_CI_SCRIPT="http://gitlab.local:10080/home1-oss/oss-build/raw/develop/src/main/ci-script/lib_ci.sh"; fi
echo "eval \$(curl -s -L ${LIB_CI_SCRIPT})"
#eval "$(curl -s -L https://github.com/home1-oss/home1-oss/raw/master/src/main/resources/oss_repositories.sh)"
eval "$(curl -s -L ${LIB_CI_SCRIPT})"
### OSS CI CALL REMOTE CI SCRIPT END

# ignore error on file not found (find and grep)
set +e
(cd src/gitbook; $@)
