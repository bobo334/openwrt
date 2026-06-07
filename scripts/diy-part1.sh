#!/bin/bash
# 在 feeds update 之前执行：拉取 luci-theme-edge2 并注册为本地 feed

set -e

echo "Cloning luci-theme-edge2 with mirror fallback ..."
rm -rf package/custom/luci-theme-edge2
mkdir -p package/custom

bash "$GITHUB_WORKSPACE/scripts/git-clone-mirror.sh" \
  debug package/custom/luci-theme-edge2 yuos-bit/luci-theme-edge2.git

echo "Register custom feed for edge2 theme ..."
echo "src-link custom ./package/custom" >> feeds.conf.default

echo "diy-part1.sh done"
