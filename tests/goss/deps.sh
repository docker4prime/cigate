#!/bin/bash
# download goss binaries from github
# - variables set here can be overriden through build/environment variables
toolname="goss"

# exit on error(s)
set -e

# -- base download url
[[ -z "$GOSS_BASEURL" ]] && GOSS_BASEURL="https://github.com/aelsabbahy/goss/releases"

# -- version to be downloaded
[[ -z "$GOSS_VERSION" ]] && GOSS_VERSION="latest"

# -- how to get latest available version
versions_latest=$(curl -sI ${GOSS_BASEURL}/latest 2>&1| grep '^Location:' | awk -F '/' '{print $NF}' | tr -d "\r" )

# -- compute version to download
[[ "$GOSS_VERSION" == "latest" ]] && GOSS_VERSION="$versions_latest"


# -- compute download url
[[ "$(uname -m)" == "x86_64" ]] && download_url_suffix="-linux-amd64" || download_url_suffix="-linux-386"
if [[ -n "$download_url_suffix" ]];then
  download_url="${GOSS_BASEURL}/download/${GOSS_VERSION}/goss${download_url_suffix}"
  # dgoss url
  dgoss_download_url="https://raw.githubusercontent.com/aelsabbahy/goss/${GOSS_VERSION}/extras/dgoss/dgoss"
fi

# -- download & install to venv bin location
[[ -n "${APP_PATH}" ]] && target_dir="${APP_PATH}/bin" || target_dir="/usr/local/bin"
if [[ -n "${download_url}" ]];then
  echo "[${toolname}] DOWNLOADING from ${download_url} ..."
  curl -ksL "${download_url}" -o ${target_dir}/goss
  [[ -x ${target_dir}/goss ]] || chmod +x ${target_dir}/goss
  echo -n "[$toolname] TESTING current version ... "
  ${target_dir}/goss --version
fi
# dgoss
if [[ -n "${dgoss_download_url}" ]];then
  echo "[${toolname}] DOWNLOADING dgoss wrapper from ${dgoss_download_url} ..."
  curl -ksL "${dgoss_download_url}" -o ${target_dir}/dgoss
  [[ -x ${target_dir}/dgoss ]] || chmod +x ${target_dir}/dgoss
fi


# eof
