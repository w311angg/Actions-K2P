#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Modify default settings
cp $GITHUB_WORKSPACE/default-settings .
echo >> default-settings
sed -n -i -e '/rm -rf \/tmp\/luci-modulecache\//r default-settings' -e 1x -e '2,${x;p}' -e '${x;p}' package/lean/default-settings/files/zzz-default-settings
rm default-settings

# Patch
for i in $GITHUB_WORKSPACE/patches/*; do patch -p0 < $i; done

#打开bbr加速
sed -i "s/option bbr_cca '0'/option bbr_cca '1'/" feeds/luci/applications/luci-app-turboacc/root/etc/config/turboacc

#清空ssrplus黑名单
echo > package/feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/deny.list

#chinadns-ng: 设置监听端口为pdnsd上游DNS端口5353
sed -i "s/option bind_port.*/option bind_port '5353'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng: 开启公平模式
sed -i "s/option fair_mode '0'/option fair_mode '1'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng: 监听本机127.0.0.1
sed -i "s/option bind_addr '0.0.0.0'/option bind_addr '127.0.0.1'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng: 信任DNS为dns2tcp
sed -i "s/option trust_dns.*/option trust_dns '127.0.0.1#1053'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng: 关闭多线程复用端口，减少内存占用
sed -i "s/option reuse_port '1'/option reuse_port '0'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng: 同一地址对dns2tcp发送1次查询包
sed -i "s/option repeat_times.*/option repeat_times '1'/" package/chinadns-ng/files/chinadns-ng.config
