#!/usr/bin/env bash






export BUILD_PUBLISH_DEPLOY_SEGREGATION="true"
export BUILD_SITE_PATH_PREFIX="oss"






### OSS CI CALL REMOTE CI SCRIPT BEGIN
if [ -z "${LIB_CI_SCRIPT}" ]; then LIB_CI_SCRIPT="https://github.com/home1-oss/oss-build/raw/master/src/main/ci-script/lib_ci.sh"; fi
#if [ -z "${LIB_CI_SCRIPT}" ]; then LIB_CI_SCRIPT="http://gitlab.local:10080/home1-oss/oss-build/raw/develop/src/main/ci-script/lib_ci.sh"; fi
echo "eval \$(curl -s -L ${LIB_CI_SCRIPT})"
#eval "$(curl -s -L ${LIB_CI_SCRIPT})"
source src/main/ci-script/lib_ci.sh
### OSS CI CALL REMOTE CI SCRIPT END

function get_git_domain() {
  local git_service="${1}"
  local git_host_port=$(echo ${git_service} | awk -F/ '{print $3}')
  if [[ "${git_service}" == *gitlab.local:* ]]; then
    echo ${git_host_port} | sed -E 's#:[0-9]+$##'
  else
    echo ${git_host_port}
  fi
}

# TODO fix build script
eval "$(curl -s -L https://github.com/home1-oss/oss-build/raw/master/src/main/install/oss_repositories.sh)"
echo "BUILD_PUBLISH_CHANNEL: ${BUILD_PUBLISH_CHANNEL}"
echo "INFRASTRUCTURE: ${INFRASTRUCTURE}"
source_git_domain="$(get_git_domain "${GIT_SERVICE}")"
echo "source_git_domain: ${source_git_domain}"

if [ "test_and_build" == "${1}" ]; then
  echo "build gitbook"
  if [ ! -d src/gitbook/oss-workspace ]; then
        mkdir -p src/gitbook/oss-workspace
  fi
  (cd src/gitbook/oss-workspace; clone_oss_repositories "${source_git_domain}")
  for repository in ${!OSS_REPOSITORIES_DICT[@]}; do
    source_git_branch=""
    if [ "release" == "${BUILD_PUBLISH_CHANNEL}" ]; then source_git_branch="master"; else source_git_branch="develop"; fi
    echo "git checkout ${source_git_branch} of ${repository}"
    (cd src/gitbook/oss-workspace/${repository}; git checkout ${source_git_branch} && git pull)
  done
  (cd src/gitbook; ./book.sh "build" "oss-workspace")
else
  echo "upload gitbook"
  (cd src/gitbook; ./book.sh "deploy" "${INFRASTRUCTURE}")
fi
