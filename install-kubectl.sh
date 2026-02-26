#!/bin/bash

versions="${KUBECTL_VERSIONS:-1.27.0 1.28.0 1.29.0 1.30.0 1.31.0 1.32.0}"
KUBECTL_INSTALL_DIR="${KUBECTL_INSTALL_DIR:-/usr/local/bin}"


mkdir -p $KUBECTL_INSTALL_DIR
for version in $versions; do
  KUBECTL_FILE=$KUBECTL_INSTALL_DIR/kubectl-v$version
  echo "Installing kubectl v$version to $KUBECTL_FILE"
  curl -L https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl -o $KUBECTL_FILE
  chmod a+x $KUBECTL_FILE
  shortver=$(echo $version | cut -d. -f2)
  echo alias k$shortver="$KUBECTL_FILE" >> k8s_aliases
done
echo alias k=$KUBECTL_FILE >> k8s_aliases