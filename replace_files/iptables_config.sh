#$IPT -A SS_SPEC_WAN_FW -p tcp -m multiport --dport 85,86 -j REDIRECT --to-ports $local_port
#$IPT -I SS_SPEC_WAN_AC 1 -p tcp --dport 443 -j RETURN -d 1.1.1.1
#$IPT -I SS_SPEC_WAN_AC 2 -p tcp --dport 443 -j RETURN -d 8.8.8.8
$IPT -I SS_SPEC_WAN_AC 1 -i br-lan -p udp --dport 53 -j RETURN
$IPT -I SS_SPEC_WAN_AC 2 -i br-lan -p tcp --dport 53 -j RETURN
#$IPT -I SS_SPEC_WAN_AC 1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -j RETURN
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m set ! --match-set blacklist dst -j RETURN || true
