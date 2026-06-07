#!/bin/bash
# defconfig 之后再次强制去掉常见大包，防止被依赖链拉回

set -e

echo "Running post-defconfig package trim ..."

source "$GITHUB_WORKSPACE/scripts/config-helper.sh"

TRIM_PACKAGES=(
  ppp
  ppp-mod-pppoe
  luci-proto-ppp
  luci-lib-ipkg
  luci-i18n-firewall-zh-cn
  luci-i18n-opkg-zh-cn
  luci-app-opkg
  kmod-nft-offload
  kmod-usb-core
  kmod-usb2
  nano
  vim
  tcpdump
  iperf3
  nmap
  wget
)

for PACKAGE in "${TRIM_PACKAGES[@]}"; do
  setPackageDisabled "$PACKAGE"
done

# 再次确认内核不带调试信息
setConfigDisabled "CONFIG_KERNEL_DEBUG_INFO"
setConfigDisabled "CONFIG_KERNEL_KALLSYMS"
setConfigEnabled "CONFIG_USE_MKLIBS"

echo "trim-config.sh done"
