#!/bin/bash
# 在 make defconfig 之后、编译之前执行：设置默认 Edge 主题与简体中文

set -e

source "$GITHUB_WORKSPACE/scripts/config-helper.sh"

echo "Setting default LuCI theme to edge2 ..."

# 把 luci / luci-light 集合里的默认 bootstrap 主题替换成 edge2
for makeFile in feeds/luci/collections/luci/Makefile feeds/luci/collections/luci-light/Makefile; do
  if [ -f "$makeFile" ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-edge2/g' "$makeFile"
    echo "Patched: $makeFile"
  fi
done

# 复制首次启动脚本：默认中文 + edge2 主题
echo "Installing uci-defaults for zh-cn and edge2 theme ..."
mkdir -p files/etc/uci-defaults
cp "$GITHUB_WORKSPACE/files/etc/uci-defaults/99-defaults-luci" files/etc/uci-defaults/99-defaults-luci
chmod +x files/etc/uci-defaults/99-defaults-luci

# 选中 edge2 主题、基础中文、IPv6
setPackageEnabled "luci-theme-edge2"
setPackageEnabled "luci-i18n-base-zh-cn"
setConfigEnabled "CONFIG_LUCI_LANG_zh_Hans"
setPackageDisabled "luci-theme-bootstrap"
setPackageDisabled "luci-theme-openwrt-2020"

IPV6_PACKAGES=(odhcp6c odhcpd-ipv6only luci-proto-ipv6)
for PACKAGE in "${IPV6_PACKAGES[@]}"; do
  setPackageEnabled "$PACKAGE"
done

# defconfig 后再瘦身一轮
bash "$GITHUB_WORKSPACE/scripts/trim-config.sh"
make defconfig
bash "$GITHUB_WORKSPACE/scripts/trim-config.sh"

# trim 用 sed 改 .config 后会 out of sync，必须 oldconfig 同步（不能用 olddefconfig）
for PACKAGE in "${IPV6_PACKAGES[@]}"; do
  setPackageEnabled "$PACKAGE"
done
setPackageEnabled "luci-theme-edge2"
setPackageEnabled "luci-i18n-base-zh-cn"
setConfigEnabled "CONFIG_LUCI_LANG_zh_Hans"

echo "Syncing .config with make oldconfig ..."
yes "" | make oldconfig

echo "=== IPv6 in final .config ==="
grep -E '^CONFIG_PACKAGE_(odhcp6c|odhcpd-ipv6only|luci-proto-ipv6)=' .config || true

echo "diy-part2.sh done"
