#!/bin/bash
# 在 make defconfig 之后、编译之前执行：设置默认 Edge 主题与简体中文

set -e

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

# 确保 edge2 主题与基础中文语言包被选中（不装额外 i18n 分包）
echo "CONFIG_PACKAGE_luci-theme-edge2=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-base-zh-cn=y" >> .config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config

# 去掉体积较大的默认主题（若已被选中）
sed -i '/CONFIG_PACKAGE_luci-theme-bootstrap=y/d' .config || true
sed -i '/CONFIG_PACKAGE_luci-theme-openwrt-2020=y/d' .config || true

# defconfig 后再瘦身一轮
bash "$GITHUB_WORKSPACE/scripts/trim-config.sh"
make defconfig
bash "$GITHUB_WORKSPACE/scripts/trim-config.sh"

# 强制保留 IPv6（避免 defconfig/trim 来回覆盖）
echo "Ensuring IPv6 packages stay enabled ..."
IPV6_PACKAGES=(odhcp6c odhcpd-ipv6only luci-proto-ipv6)
for PACKAGE in "${IPV6_PACKAGES[@]}"; do
  ./scripts/config/conf --enable "CONFIG_PACKAGE_${PACKAGE}"
done
make olddefconfig

echo "=== IPv6 in final .config ==="
grep -E '^CONFIG_PACKAGE_(odhcp6c|odhcpd-ipv6only|luci-proto-ipv6)=' .config || true

echo "diy-part2.sh done"
