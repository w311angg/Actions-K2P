ipset -N bplanmac hash:mac 2>/dev/null
ipset -N whitelist hash:net 2>/dev/null
ipset -N china hash:net 2>/dev/null

#bropc
ipset -N gfwlist hash:net 2>/dev/null

#bplan
ipset -N bplan_dns hash:net 2>/dev/null; ipset flush bplan_dns; ipset add bplan_dns 223.5.5.5 2>/dev/null; ipset add bplan_dns 223.6.6.6 2>/dev/null
ipset -N bplan_dns6 hash:net family inet6 2>/dev/null; ipset flush bplan_dns6; ipset add bplan_dns6 2400:3200::1 2>/dev/null; ipset add bplan_dns6 2400:3200:baba::1 2>/dev/null

#specific domain block quic
ipset -N quic_blocking hash:net 2>/dev/null

iptables -t filter -N SS_SPEC_CUS_LAN_FWD
iptables -t filter -I zone_lan_forward 1 --comment _SS_SPEC_RULE_ -j SS_SPEC_CUS_LAN_FWD
iptables -t filter -A SS_SPEC_CUS_LAN_FWD -m set --match-set bplanmac src -j RETURN

#specific domain block quic
iptables -t filter -A SS_SPEC_CUS_LAN_FWD -o eth1 -p udp -m multiport --dport 80,443 -m set --match-set quic_blocking dst -j REJECT

#iptables -t filter -A SS_SPEC_CUS_LAN_FWD -o eth1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -m set ! --match-set whitelist dst -j REJECT
#iptables -t filter -A SS_SPEC_CUS_LAN_FWD -p tcp -d 1.1.1.1 --dport 443 -j REJECT --reject-with tcp-reset
#iptables -t filter -A SS_SPEC_CUS_LAN_FWD -p tcp -d 8.8.8.8 --dport 443 -j REJECT --reject-with tcp-reset

iptables -t nat -N SS_SPEC_CUS_WAN_AC
iptables -t nat -I PREROUTING 2 --comment _SS_SPEC_RULE_ -j SS_SPEC_CUS_WAN_AC

#bplan
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -m set --match-set bplanmac src -m set --match-set bplan_dns dst --dport 53 -j REDIRECT --to-ports 5336
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -m set --match-set bplanmac src -m set --match-set bplan_dns dst --dport 53 -j REDIRECT --to-ports 5336

iptables -t nat -A SS_SPEC_CUS_WAN_AC -m set --match-set bplanmac src -j RETURN
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -d 192.168.0.0/16 --dport 53 -j RETURN
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -d 192.168.0.0/16 --dport 53 -j RETURN

#bropc
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
iptables -t nat -A SS_SPEC_CUS_WAN_AC -m set --match-set bropc src -j RETURN

iptables -t nat -A SS_SPEC_CUS_WAN_AC -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp --dport 53 -j REDIRECT --to-ports 53

[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -N SS_SPEC_CUS_WAN_AC
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -I PREROUTING 1 --comment _SS_SPEC_RULE_ -j SS_SPEC_CUS_WAN_AC

#bplan
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -m set --match-set bplanmac src -m set --match-set bplan_dns6 dst --dport 53 -j REDIRECT --to-ports 5336
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -m set --match-set bplanmac src -m set --match-set bplan_dns6 dst --dport 53 -j REDIRECT --to-ports 5336

[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -m set --match-set bplanmac src -j RETURN
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -d FC00::/7 --dport 53 -j RETURN
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -d FC00::/7 --dport 53 -j RETURN

#bropc
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -m set --match-set bropc src -j RETURN

[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp --dport 53 -j REDIRECT --to-ports 53
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp --dport 53 -j REDIRECT --to-ports 53


#------------------


#$IPT -A SS_SPEC_WAN_FW -p tcp -m multiport --dport 85,86 -j REDIRECT --to-ports $local_port
#$IPT -I SS_SPEC_WAN_AC 1 -p tcp --dport 443 -j RETURN -d 1.1.1.1
#$IPT -I SS_SPEC_WAN_AC 2 -p tcp --dport 443 -j RETURN -d 8.8.8.8
$IPT -I SS_SPEC_WAN_AC 1 -i br-lan -p udp --dport 53 -j RETURN
$IPT -I SS_SPEC_WAN_AC 2 -i br-lan -p tcp --dport 53 -j RETURN
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -m set ! --match-set whitelist dst -j RETURN
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m set ! --match-set blacklist dst -j RETURN

#specific domain block quic
iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m multiport --dport 80,443 -m set --match-set quic_blocking dst -j RETURN

#google one vpn bypass
iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp --dport 2153 -m set --match-set googlevpn_lan src -j RETURN

#bropc
iptables -t mangle -I SS_SPEC_TPROXY 1 -m set --match-set bropc src -m set ! --match-set bplanmac src -p udp -j RETURN
$IPT -I SS_SPEC_WAN_FW $(($(iptables -L SS_SPEC_WAN_FW -t nat | wc -l)-2)) -m set --match-set bropc src -p tcp -m multiport --dports 22,53,587,465,995,993,143,80,443,853,9418 -j REDIRECT --to-ports 1234
$IPT -I SS_SPEC_WAN_FW $(($(iptables -L SS_SPEC_WAN_FW -t nat | wc -l)-2)) -m set --match-set bropc src -j RETURN
