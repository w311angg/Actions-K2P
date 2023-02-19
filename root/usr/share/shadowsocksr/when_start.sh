#重启后不会消失的需要加以判断
if [[ "$(uci get dnsforwarder.@arguments[0].enabled)" != '1' ]]; then
  uci set dnsforwarder.@arguments[0].enabled='1'
  uci commit
  /etc/init.d/dnsforwarder reload
fi
(tcp2udp 127.0.0.1:5333 :5333 >/dev/null 2>&1)&
ipset -! -R <<-EOF
	create china6 hash:net family inet6
	$(cat /etc/ssrplus/china6_ssr.txt | sed -e "s/^/add china6 /")
EOF

#bropc
/usr/share/dnsforwarder-bropc/genlist.sh custom >/dev/null
ln -s /usr/bin/dnsforwarder /tmp/dnsforwarder-bropc
/tmp/dnsforwarder-bropc -d -f /etc/dnsforwarder-bropc/dnsforwarder.config
