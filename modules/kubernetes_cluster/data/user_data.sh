#!/bin/bash
# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

NODEUP_URL=https://kubeupv2.s3.amazonaws.com/kops/1.7.0/linux/amd64/nodeup
NODEUP_HASH=




function ensure-install-dir() {
  INSTALL_DIR="/var/cache/kubernetes-install"
  # On ContainerOS, we install to /var/lib/toolbox install (because of noexec)
  if [[ -d /var/lib/toolbox ]]; then
    INSTALL_DIR="/var/lib/toolbox/kubernetes-install"
  fi
  mkdir -p ${INSTALL_DIR}
  cd ${INSTALL_DIR}
}

# Retry a download until we get it. Takes a hash and a set of URLs.
#
# $1 is the sha1 of the URL. Can be "" if the sha1 is unknown.
# $2+ are the URLs to download.
download-or-bust() {
  local -r hash="$1"
  shift 1

  urls=( $* )
  while true; do
    for url in "${urls[@]}"; do
      local file="${url##*/}"
      rm -f "${file}"
      if ! curl -f --ipv4 -Lo "${file}" --connect-timeout 20 --retry 6 --retry-delay 10 "${url}"; then
        echo "== Failed to download ${url}. Retrying. =="
      elif [[ -n "${hash}" ]] && ! validate-hash "${file}" "${hash}"; then
        echo "== Hash validation of ${url} failed. Retrying. =="
      else
        if [[ -n "${hash}" ]]; then
          echo "== Downloaded ${url} (SHA1 = ${hash}) =="
        else
          echo "== Downloaded ${url} =="
        fi
        return
      fi
    done

    echo "All downloads failed; sleeping before retrying"
    sleep 60
  done
}

validate-hash() {
  local -r file="$1"
  local -r expected="$2"
  local actual

  actual=$(sha1sum ${file} | awk '{ print $1 }') || true
  if [[ "${actual}" != "${expected}" ]]; then
    echo "== ${file} corrupted, sha1 ${actual} doesn't match expected ${expected} =="
    return 1
  fi
}

function split-commas() {
  echo $1 | tr "," "\n"
}

function try-download-release() {
  # TODO(zmerlynn): Now we REALLY have no excuse not to do the reboot
  # optimization.

  local -r nodeup_urls=( $(split-commas "${NODEUP_URL}") )
  local -r nodeup_filename="${nodeup_urls[0]##*/}"
  if [[ -n "${NODEUP_HASH:-}" ]]; then
    local -r nodeup_hash="${NODEUP_HASH}"
  else
  # TODO: Remove?
    echo "Downloading sha1 (not found in env)"
    download-or-bust "" "${nodeup_urls[@]/%/.sha1}"
    local -r nodeup_hash=$(cat "${nodeup_filename}.sha1")
  fi

  echo "Downloading nodeup (${nodeup_urls[@]})"
  download-or-bust "${nodeup_hash}" "${nodeup_urls[@]}"

  chmod +x nodeup
}

function download-release() {
  # In case of failure checking integrity of release, retry.
  until try-download-release; do
    sleep 15
    echo "Couldn't download release. Retrying..."
  done

  echo "Running nodeup"
  # We can't run in the foreground because of https://github.com/docker/docker/issues/23793
  ( cd ${INSTALL_DIR}; ./nodeup --install-systemd-unit --conf=${INSTALL_DIR}/kube_env.yaml --v=8  )
}

####################################################################################

/bin/systemd-machine-id-setup || echo "failed to set up ensure machine-id configured"
