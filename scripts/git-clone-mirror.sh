#!/bin/bash
# 从 GitHub 直连克隆仓库（Actions runner 无需镜像）

set -e

if [ "$#" -lt 3 ]; then
  echo "Usage: git-clone-mirror.sh <branch_or_tag> <dest_dir> <github_repo_path>"
  echo "Example: git-clone-mirror.sh v25.12.4 openwrt-src openwrt/openwrt.git"
  exit 1
fi

BRANCH="$1"
DEST="$2"
REPO_PATH="$3"
URL="https://github.com/${REPO_PATH}"

echo "Cloning ${URL} (branch/tag: ${BRANCH}) ..."
git clone --depth=1 --branch "${BRANCH}" "${URL}" "${DEST}"
echo "Clone OK: ${URL}"
