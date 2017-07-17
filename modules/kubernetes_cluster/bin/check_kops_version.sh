#!/usr/bin/env bash

set -eu -o pipefail

USER_DATA_FILE=$1

MODULE_VERSION=$(grep -m1 NODEUP_URL $USER_DATA_FILE | cut -f5 -d'/')
KOPS_VERSION=$(kops version | awk '{print $2}')

if [ "$MODULE_VERSION" != "$KOPS_VERSION" ]; then
  echo "kops version ${KOPS_VERSION} and module version ${MODULE_VERSION} do not match"
  exit 1
else
  echo "kops version ${KOPS_VERSION} supported"
fi
