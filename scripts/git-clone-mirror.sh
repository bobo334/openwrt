#!/bin/bash
# 通过 GitHub 镜像克隆仓库，镜像失败时自动回退到直连 GitHub

set -e

if [ "$#" -lt 3 ]; then
  echo "Usage: git-clone-mirror.sh <branch_or_tag> <dest_dir> <github_repo_path>"
  echo "Example: git-clone-mirror.sh v25.12.4 openwrt-src openwrt/openwrt.git"
  exit 1
fi

BRANCH="$1"
DEST="$2"
REPO_PATH="$3"

MIRRORS=(
  "${GITHUB_MIRROR:-https://ghproxy.net/}https://github.com/${REPO_PATH}"
  "https://ghfast.top/https://github.com/${REPO_PATH}"
  "https://mirror.ghproxy.com/https://github.com/${REPO_PATH}"
  "https://github.com/${REPO_PATH}"
)

for URL in "${MIRRORS[@]}"; do
  echo "Trying clone: ${URL} (branch/tag: ${BRANCH})"
  if git clone --depth=1 --branch "${BRANCH}" "${URL}" "${DEST}"; then
    echo "Clone OK: ${URL}"
    exit 0
  fi
  rm -rf "${DEST}"
done

echo "ERROR: all mirror attempts failed for ${REPO_PATH}"
exit 1
