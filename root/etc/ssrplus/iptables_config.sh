function get_rule_number() {
	input=""
	while read -r line; do
		input="$input$line
"
	done
	echo "$input" | awk 'NR>2' | awk "{count++} /$1/{print count; exit}"
}


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

#block dns over any except udp/tcp
dns='1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4'
dns6='2606:4700::1111 2606:4700:4700::1001 2001:4860:4860::8888 2001:4860:4860::8844'
ipset -N dns hash:net 2>/dev/null; ipset flush dns; for ip in $dns; do ipset add dns $ip 2>/dev/null; done
ipset -N dns6 hash:net family inet6 2>/dev/null; ipset flush dns6; for ip6 in $dns6; do ipset add dns6 $ip6 2>/dev/null; done

iptables -t filter -A SS_SPEC_CUS_LAN_FWD -m set --match-set bplanmac src -j RETURN

#block dns over any except udp/tcp
iptables -t filter -A SS_SPEC_CUS_LAN_FWD -p udp -m set --match-set dns dst ! --dport 53 -j REJECT
iptables -t filter -A SS_SPEC_CUS_LAN_FWD -p tcp -m set --match-set dns dst ! --dport 53 -j REJECT --reject-with tcp-reset

#specific domain block quic
iptables -t filter -A SS_SPEC_CUS_LAN_FWD -o eth1 -p udp -m multiport --dport 80,443 -m set --match-set quic_blocking dst -j REJECT

#iptables -t filter -A SS_SPEC_CUS_LAN_FWD -o eth1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -m set ! --match-set whitelist dst -j REJECT

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

if [ -n "$(command -v ip6tables)" ]; then
	ip6tables -t filter -A SS_SPEC_CUS_LAN_FWD -m set --match-set bplanmac src -j RETURN

	#block dns over any except udp/tcp
	ip6tables -t filter -A SS_SPEC_CUS_LAN_FWD -p udp -m set --match-set dns6 dst ! --dport 53 -j REJECT
	ip6tables -t filter -A SS_SPEC_CUS_LAN_FWD -p tcp -m set --match-set dns6 dst ! --dport 53 -j REJECT --reject-with tcp-reset

	#bplan
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -m set --match-set bplanmac src -m set --match-set bplan_dns6 dst --dport 53 -j REDIRECT --to-ports 5336
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -m set --match-set bplanmac src -m set --match-set bplan_dns6 dst --dport 53 -j REDIRECT --to-ports 5336

	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -m set --match-set bplanmac src -j RETURN
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -d FC00::/7 --dport 53 -j RETURN
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -d FC00::/7 --dport 53 -j RETURN

	#bropc
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -m set --match-set bropc src -j RETURN

	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p udp --dport 53 -j REDIRECT --to-ports 53
	ip6tables -t nat -A SS_SPEC_CUS_WAN_AC -p tcp --dport 53 -j REDIRECT --to-ports 53
fi


#------------------


#$IPT -A SS_SPEC_WAN_FW -p tcp -m multiport --dport 85,86 -j REDIRECT --to-ports $local_port
$IPT -I SS_SPEC_WAN_AC 1 -i br-lan -p udp --dport 53 -j RETURN
$IPT -I SS_SPEC_WAN_AC 2 -i br-lan -p tcp --dport 53 -j RETURN
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -m set ! --match-set whitelist dst -j RETURN
#iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m set ! --match-set blacklist dst -j RETURN

#bropc
iptables -t mangle -I SS_SPEC_TPROXY $(iptables -t mangle -L SS_SPEC_TPROXY | get_rule_number 'match-set china dst ! match-set blacklist dst') -m set --match-set bropc src -m set ! --match-set bplanmac src -p udp -m set --match-set blacklist dst -j TPROXY --on-port 1234 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1
iptables -t mangle -I SS_SPEC_TPROXY $(iptables -t mangle -L SS_SPEC_TPROXY | get_rule_number 'match-set china dst ! match-set blacklist dst') -m set --match-set bropc src -m set ! --match-set bplanmac src -p udp -m set --match-set gfwlist dst -j TPROXY --on-port 1234 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1
iptables -t mangle -I SS_SPEC_TPROXY $(iptables -t mangle -L SS_SPEC_TPROXY | get_rule_number 'match-set china dst ! match-set blacklist dst') -m set --match-set bropc src -m set ! --match-set bplanmac src -p udp -j RETURN
$IPT -I SS_SPEC_WAN_AC $(iptables -t nat -L SS_SPEC_WAN_AC | get_rule_number 'match-set china dst') -m set --match-set bropc src -m set --match-set gfwlist dst -j SS_SPEC_WAN_FW
$IPT -I SS_SPEC_WAN_AC $(iptables -t nat -L SS_SPEC_WAN_AC | get_rule_number 'match-set china dst') -m set --match-set bropc src -j RETURN

#specific domain block quic
iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m multiport --dport 80,443 -m set --match-set quic_blocking dst -j RETURN

#google one vpn bypass
iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp --dport 2153 -m set --match-set googlevpn_lan src -j RETURN

#block dns over any except udp/tcp
iptables -t mangle -I SS_SPEC_TPROXY 1 -p udp -m set --match-set dns dst ! --dport 53 -j RETURN
$IPT -I SS_SPEC_WAN_AC 1 -p tcp -m set --match-set dns dst ! --dport 53 -j RETURN
