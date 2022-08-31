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
for i in $GITHUB_WORKSPACE/patches/*.patch; do patch -p0 < $i; done

# Set permissions
chmod +x package/feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/iptables_config.sh

#打开bbr加速
sed -i "s/option bbr_cca.*/option bbr_cca '1'/" feeds/luci/applications/luci-app-turboacc/root/etc/config/turboacc

#清空ssrplus黑名单
echo > package/feeds/helloworld/luci-app-ssr-plus/root/etc/ssrplus/deny.list

#ssrplus访问国外域名DNS服务器设为1.0.0.1
sed -i "s/tunnel_forward=.*/tunnel_forward='1.0.0.1:53'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus使用本机5335端口
sed -i "s/pdnsd_enable=.*/pdnsd_enable='0'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#ssrplus全端口代理
sed -i "s/dports=.*/dports='1'/" feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr

#dnsmasq禁止解析IPv6 DNS记录
#sed -i "s/option filter_aaaa.*/option filter_aaaa	1/" package/network/services/dnsmasq/files/dhcp.conf

#清空chinadns-ng gfwlist chinalist
echo > package/chinadns-ng/files/gfwlist.txt
echo > package/chinadns-ng/files/chinalist.txt

#关闭chinadns-ng多进程端口复用
sed -i "s/option reuse_port.*/option reuse_port '0'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng开启公平模式
sed -i "s/option fair_mode.*/option fair_mode '1'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng监听本机127.0.0.1
sed -i "s/option bind_addr.*/option bind_addr '127.0.0.1'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng信任DNS为dnsforwarder
sed -i "s/option trust_dns.*/option trust_dns '127.0.0.1#5335'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng白名单改为ssrplus白名单
sed -i "s/option chnlist_file.*/option chnlist_file '\/etc\/ssrplus\/white.list'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng黑名单改为自定义黑名单
sed -i "s/option gfwlist_file.*/option gfwlist_file '\/etc\/chinadns-ng\/blacklist.txt'/" package/chinadns-ng/files/chinadns-ng.config

#chinadns-ng国内路由表优先
sed -i "s/option chnlist_first.*/option chnlist_first '1'/" package/chinadns-ng/files/chinadns-ng.config

#修改dnsforwarder配置
cp $GITHUB_WORKSPACE/replace_files/dnsforwarder.config feeds/packages/net/dnsforwarder/files/etc/config/dnsforwarder

#清空dnsforwarder无用文件
echo > feeds/packages/net/dnsforwarder/files/etc/dnsforwarder/gfw.txt
