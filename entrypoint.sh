#!/bin/sh

set -e
K3D_VERSION=$1
CLUSTER_NAME=$2
SKIP_CLUSTER_CREATION=$3

REPO_URL="https://github.com/rancher/k3d"
K3D_ROOT="/usr/local/k3d"

if [ "$K3D_VERSION" = "latest" ]; then
  local latest_release_url="${REPO_URL}/releases/latest"
  K3D_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} $latest_release_url | grep -oE "[^/]+$" )
fi

echo "Install k3d ${K3D_VERSION}."

mkdir -p "${K3D_ROOT}/bin"

curl -SsL "${REPO_URL}/releases/download/${K3D_VERSION}/k3d-linux-amd64" -o "${K3D_ROOT}/bin/k3d"

chmod a+x "${K3D_ROOT}/bin/k3d"

export PATH="${PATH}:${K3D_ROOT}/bin"

echo "${K3D_ROOT}/bin" >> $GITHUB_PATH

echo "Finished to install k3d."

if [ ! "$SKIP_CLUSTER_CREATION" = "true" ]; then
    echo "Creating k3d cluster..."

    k3d cluster create ${CLUSTER_NAME}
    k3d kubeconfig merge ${CLUSTER_NAME} --switch-context

    echo "Finished to create k3d cluster."
fi