#!/bin/sh
# PURPOSE: simple wrapper script for running tests


# -- auto: path variables
scriptSelf=$0;
scriptName=$(basename $scriptSelf)
scriptCallDir=$(dirname $scriptSelf)
scriptFullDir=$(cd $scriptCallDir;echo $PWD)
scriptFullPath=$scriptFullDir/$scriptName;
scriptParentDir=$(dirname $scriptFullDir)
# -- /auto: path variables


# -- setup environment
# if running from app container itself
if [ -n "${APP_NAME}" ];then
  # install required OS packages
  OS_PACKAGES="bash curl git"
  apk add --no-cache ${OS_PACKAGES}
  # run dependency script
  DEPSFILE=${scriptFullDir}/deps.sh
  if [ -f ${DEPSFILE} ];then
    echo "[>] running dependency script (${DEPSFILE})"
    /bin/sh ${DEPSFILE}
  fi
fi


# -- run goss tests
PROJECT_DIRNAME=$(dirname ${scriptParentDir}|xargs basename)
[ -z "${DOCKER_IMAGE}" ] && DOCKER_IMAGE="docker4prime/${PROJECT_DIRNAME}"
[ -z "${GOSSFILE_PATH}" ] && GOSSFILE_PATH=${scriptFullDir}/goss.yml
# if running from app container itself
if [ -n "${APP_NAME}" ];then
  echo "[>] running goss test defined in ${GOSSFILE_PATH} (from app ${APP_NAME})"
  goss --gossfile ${GOSSFILE_PATH} validate -f documentation
# if running from external docker host
else
  if docker version >/dev/null 2>&1;then
    echo "[>] running goss test defined in ${GOSSFILE_PATH} (by starting docker image ${DOCKER_IMAGE})"
    docker run --rm -it -e APP_NAME=${PROJECT_DIRNAME} -v ${scriptFullDir}:/tmp/goss ${DOCKER_IMAGE} sh /tmp/goss/goss.sh
  fi
fi


# eof
