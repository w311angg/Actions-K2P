#$IPT -A SS_SPEC_WAN_FW -p tcp -m multiport --dport 85,86 -j REDIRECT --to-ports $local_port
#$IPT -I SS_SPEC_WAN_AC 1 -p tcp --dport 443 -j RETURN -d 1.1.1.1
#$IPT -I SS_SPEC_WAN_AC 2 -p tcp --dport 443 -j RETURN -d 8.8.8.8
$IPT -I SS_SPEC_WAN_AC 1 -i br-lan -p udp --dport 53 -j RETURN
$IPT -I SS_SPEC_WAN_AC 2 -i br-lan -p tcp --dport 53 -j RETURN
#$IPT -I SS_SPEC_WAN_AC 1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -j RETURN
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m set ! --match-set blacklist dst -j RETURN || true

#specific domain block quic
#/usr/share/ssrplus/quic_blocking_genconf.sh
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m multiport --dport 80,443 -m set --match-set quic_blocking dst -j RETURN

#google one vpn bypass
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp --dport 2153 -m set --match-set googlevpn_lan src -j RETURN

#bropc
#iptables -t mangle -I SS_SPEC_TPROXY 1 -m set --match-set bropc src -m set ! --match-set bplanmac src -p udp -j RETURN
#$IPT -I SS_SPEC_WAN_FW $(($(iptables -L SS_SPEC_WAN_FW -t nat | wc -l)-2)) -m set --match-set bropc src -p tcp -m multiport --dports 22,53,587,465,995,993,143,80,443,853,9418 -j REDIRECT --to-ports 1234
#$IPT -I SS_SPEC_WAN_FW $(($(iptables -L SS_SPEC_WAN_FW -t nat | wc -l)-2)) -m set --match-set bropc src -j RETURN
#/usr/share/dnsforwarder-bropc/genlist.sh custom
