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

#TCP全端口代理
sed -i "s/option tcp_redir_ports .*/option tcp_redir_ports '1:65535'/" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/0_default_config

#代理53-DNS端口
sed -i "s/option udp_redir_ports .*/option udp_redir_ports '53'/" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/0_default_config

#关闭passwall日志
sed -i "s/option close_log_tcp '0'/option close_log_tcp '1'/" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/0_default_config
sed -i "s/option close_log_udp '0'/option close_log_udp '1'/" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/0_default_config

#删除ssrplus对防火墙的修改
sed -i "/REDIRECT --to-ports 53' >>/d" package/lean/default-settings/files/zzz-default-settings

#过滤代理域名IPv6
sed -i "s/option filter_proxy_ipv6 '0'/option filter_proxy_ipv6 '1'/" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/0_default_config

#开启ChinaDNS-NG
sed -i "/config global/a\	option chinadns_ng '1'" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/0_default_config

#修复UDP53端口代理不起作用
sed -i "/--dport 53 -j RETURN/d" package/feeds/passwallluci/luci-app-passwall/root/usr/share/passwall/iptables.sh
