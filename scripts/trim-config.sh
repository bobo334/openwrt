#!/bin/bash
# defconfig 之后再次强制去掉常见大包，防止被依赖链拉回

set -e

echo "Running post-defconfig package trim ..."

TRIM_PACKAGES=(
  ppp
  ppp-mod-pppoe
  luci-proto-ppp
  luci-proto-ipv6
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
  odhcp6c
  odhcpd-ipv6only
)

for PACKAGE in "${TRIM_PACKAGES[@]}"; do
  ./scripts/config/conf --disable "CONFIG_PACKAGE_${PACKAGE}" 2>/dev/null || true
done

# 再次确认内核不带调试信息
./scripts/config/conf --disable CONFIG_KERNEL_DEBUG_INFO 2>/dev/null || true
./scripts/config/conf --disable CONFIG_KERNEL_KALLSYMS 2>/dev/null || true
./scripts/config/conf --enable CONFIG_USE_MKLIBS 2>/dev/null || true

echo "trim-config.sh done"
