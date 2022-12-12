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

# Exit with code 1 if error
set -e

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Modify default settings
cp $GITHUB_WORKSPACE/default-settings .
echo >> default-settings
sed -n -i -e '/rm -rf \/tmp\/luci-modulecache\//r default-settings' -e 1x -e '2,${x;p}' -e '${x;p}' package/lean/default-settings/files/zzz-default-settings
rm default-settings

# Patch
for i in $(find $GITHUB_WORKSPACE/patches/ -type f -regex ".*\.patch" | sort); do echo "using $(basename $i)"; patch -p0 < $i; done

# Set permissions
chmod +x package/feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/iptables_config.sh

#打开bbr加速
sed -i "s/option bbr_cca.*/option bbr_cca '1'/" feeds/luci/applications/luci-app-turboacc/root/etc/config/turboacc

#清空ssrplus黑名单
echo > package/feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/deny.list

#ssrplus访问国外域名DNS服务器设为1.0.0.1
sed -i "s/tunnel_forward=.*/tunnel_forward='1.0.0.1:53'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus使用本机5335端口
#sed -i "s/pdnsd_enable=.*/pdnsd_enable='0'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus全端口代理
sed -i "s/dports=.*/dports='1'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus关闭自动切换
sed -i "s/enable_switch=.*/enable_switch='0'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus不屏蔽quic
sed -i "s/block_quic=.*/block_quic='0'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus chinadns-ng创建规则文件
touch feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/chinadns_white.list
touch feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/chinadns_black.list

#ssrplus chinadns-ng`tw`域代理解析
echo 'tw' >> feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/chinadns_black.list

#dnsmasq不禁止解析IPv6 DNS记录
sed -i "s/option filter_aaaa.*/option filter_aaaa	0/" package/network/services/dnsmasq/files/dhcp.conf

#修改dnsforwarder配置
cp $GITHUB_WORKSPACE/replace_files/dnsforwarder.config feeds/packages/net/dnsforwarder/files/etc/config/dnsforwarder

#清空dnsforwarder无用文件
echo > feeds/packages/net/dnsforwarder/files/etc/dnsforwarder/gfw.txt
