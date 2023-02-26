#会在reload,restart,start,系统启动(当enabled)时运行
#重启后不会消失的需要加以判断
if [[ "$(uci get dnsforwarder.@arguments[0].enabled)" != '1' ]]; then
  uci set dnsforwarder.@arguments[0].enabled='1'
  uci commit; reload_config
fi
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

chinadns="$(uci get shadowsocksr.@global[0].chinadns_forward)"
if [ -n "$chinadns" ]; then
  ipset create chinalist hash:net
  mkdir -p /var/dnsmasq.d/dnsmasq-ssrplus.d/
  cat /etc/ssrplus/china.list | sed '/^$/d' | sed "/.*/s/.*/server=\/&\/${chinadns/:/#}\nipset=\/&\/chinalist/" >/var/dnsmasq.d/dnsmasq-ssrplus.d/china.conf
fi
