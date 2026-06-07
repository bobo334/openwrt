#!/bin/bash
# 直接修改 .config 启用/禁用选项。
# OpenWrt 自带的 scripts/config/conf 没有 --enable / --disable，用 sed 更可靠。
# 用法：在 openwrt-src 目录下 source 本文件后调用 setPackageEnabled / setPackageDisabled。

setConfigLine() {
  local key="$1"
  local value="$2"

  sed -i "/^${key}=/d" .config
  sed -i "/^# ${key} is not set/d" .config
  echo "${value}" >> .config
}


setPackageEnabled() {
  local package="$1"
  setConfigLine "CONFIG_PACKAGE_${package}" "CONFIG_PACKAGE_${package}=y"
}


setPackageDisabled() {
  local package="$1"
  setConfigLine "CONFIG_PACKAGE_${package}" "# CONFIG_PACKAGE_${package} is not set"
}


setConfigEnabled() {
  local key="$1"
  setConfigLine "${key}" "${key}=y"
}


setConfigDisabled() {
  local key="$1"
  setConfigLine "${key}" "# ${key} is not set"
}
