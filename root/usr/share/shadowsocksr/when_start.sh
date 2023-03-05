#会在reload,restart,start,系统启动(当enabled)时运行
#重启后不会消失的需要加以判断
ln -s /usr/bin/dnsforwarder /tmp/dnsforwarder-bplan
mkdir -p /var/etc/dnsforwarder-bplan
wan_dns="$(ifstatus wan | jsonfilter -e '@["dns-server"][0]' || echo '')"
cat /etc/dnsforwarder-bplan/dnsforwarder.config | sed "s/%wan_dns%/${wan_dns}$([[ -n '$wan_dns' ]] && echo ,)/" >/var/etc/dnsforwarder-bplan/dnsforwarder.config
/tmp/dnsforwarder-bplan -d -f /var/etc/dnsforwarder-bplan/dnsforwarder.config
(tcp2udp 127.0.0.1:5333 :5333 >/dev/null 2>&1)&
ipset -! -R <<-EOF
	create china6 hash:net family inet6
	$(cat /etc/ssrplus/china6_ssr.txt | sed -e "s/^/add china6 /")
EOF

#bropc
/usr/share/dnsforwarder-bropc/genlist.sh custom >/dev/null
/usr/share/dnsforwarder-bropc/genlist.sh gfwlist >/dev/null
ln -s /usr/bin/dnsforwarder /tmp/dnsforwarder-bropc
/tmp/dnsforwarder-bropc -d -f /etc/dnsforwarder-bropc/dnsforwarder.config

serverIP=$(uci get shadowsocksr.$(uci get shadowsocksr.@global[0].global_server).ip)
if [[ $(lua -e "require 'luci.ip'; print(luci.ip.new('192.168.0.0/16'):contains('$serverIP'))") == 'true' ]]; then
  uci set shadowsocksr.@global[0].chinadns_forward='127.0.0.1:5336'
  uci set shadowsocksr.@global[0].mydnsip="$serverIP"
  uci set shadowsocksr.@global[0].mydnsport='533'
  uci set dhcp.@dnsmasq[0].cachesize='0'
  uci commit
fi

#specific domain block quic
/usr/share/shadowsocksr/quic_blocking_genconf.sh >/dev/null
