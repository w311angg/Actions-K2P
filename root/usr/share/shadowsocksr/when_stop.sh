uci set dnsforwarder.@arguments[0].enabled='0'
uci commit
/etc/init.d/dnsforwarder reload
ps -w | grep -v "grep" | grep 'tcp2udp 127.0.0.1:5333 :5333' | awk '{print $1}' | xargs kill -9
ipset destroy china6

#bropc
ps -w | grep -v "grep" | grep '\[dnsforwarder-br\]' | awk '{print $1}' | xargs kill -9
rm -rf /var/etc/dnsforwarder-bropc/
rm -rf /tmp/dnsforwarder-bropc

serverIP=$(uci get shadowsocksr.$(uci get shadowsocksr.@global[0].global_server).ip)
if [[ $(lua -e "require 'luci.ip'; print(luci.ip.new('192.168.0.0/16'):contains('$serverIP'))") == 'false' ]]; then
  uci set shadowsocksr.@global[0].chinadns_forward='wan_114'
  uci set shadowsocksr.@global[0].mydnsip="127.0.0.1"
  uci set shadowsocksr.@global[0].mydnsport='5335'
  uci delete dhcp.@dnsmasq[0].cachesize
  uci commit
fi

#specific domain block quic
rm -rf /var/dnsmasq.d/dnsmasq-ssrplus.d/010_quic_blocking.conf
