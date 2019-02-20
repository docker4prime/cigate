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


# list of enabled tests
TESTS_ENABLED="goss"


# run enabled tests
for TESTNAME in ${TESTS_ENABLED}
do
  TESTPATH=${scriptFullDir}/${TESTNAME}/${TESTNAME}.sh
  if [ -f ${TESTPATH} ];then
    echo "[>] running ${TESTNAME} tests (${TESTPATH})"
    /bin/sh ${TESTPATH} $*
  fi
done


# eof
