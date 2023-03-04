#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall;packages' >>feeds.conf.default
#echo 'src-git passwallluci https://github.com/xiaorouji/openwrt-passwall;luci' >>feeds.conf.default
git clone https://github.com/w311ang/openwrt-tcp2udp.git package/tcp2udp
#git clone https://github.com/w311ang/openwrt-ipportfwd.git package/ipportfwd

#更新dnsforwarder
git clone https://github.com/lifenjoiner/dnsforwarder /tmp/dnsforwarder
cd /tmp/dnsforwarder
hash=$(git log -1 --format="%H")
date=$(git log -1 --format="%cd" --date=short)
version=$(grep -oP -m1 '(?<=#define VERSION__ ").*?(?=")' main.c)
cd -
sed {
  "s/%pkg_version%/$version/",
  "s/%pkg_source_date%/$date/",
  "s/%pkg_source_version%/$hash/"
} feeds/packages/net/dnsforwarder/Makefile

git clone https://github.com/zfl9/chinadns-ng /tmp/chinadns-ng
cd /tmp/chinadns-ng
hash=$(git log -1 --format="%H")
date=$(git log -1 --format="%cd" --date=short)
version=$(grep -oP -m1 '(?<=#define CHINADNS_VERSION "ChinaDNS-NG ).*?(?= <.*?>")' main.c)
cd -
sed {
  "s/%pkg_version%/$version/",
  "s/%pkg_source_date%/$date/",
  "s/%pkg_source_version%/$hash/"
} feeds/helloworld/chinadns-ng/Makefile
