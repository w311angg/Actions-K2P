#bropc
#ipset -N bropc hash:mac
#ipset add bropc <弟弟电脑mac>

ipset -N bplanmac hash:mac 2>/dev/null
#ipset -N whitelist hash:net 2>/dev/null
#ipset -N china hash:net 2>/dev/null
#ipset -N bplan_dns hash:net 2>/dev/null; ipset flush bplan_dns; ipset add bplan_dns 223.5.5.5; ipset add bplan_dns 223.6.6.6
#ipset -N bplan_dns6 hash:net family inet6 2>/dev/null; ipset flush bplan_dns6; ipset add bplan_dns6 2400:3200::1; ipset add bplan_dns6 2400:3200:baba::1
iptables -t filter -A forwarding_lan_rule -m set --match-set bplanmac src -j RETURN

#bropc
#iptables -t filter -A forwarding_lan_rule -m set --match-set bropc src -o eth1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -m set ! --match-set whitelist dst -j REJECT
#iptables -t filter -A forwarding_lan_rule -m set --match-set bropc src -j RETURN

#iptables -t filter -A forwarding_lan_rule -o eth1 -p udp -m multiport --dport 80,443 -m set ! --match-set china dst -m set ! --match-set whitelist dst -j REJECT
#iptables -t filter -A forwarding_lan_rule -p tcp -d 1.1.1.1 --dport 443 -j REJECT --reject-with tcp-reset
#iptables -t filter -A forwarding_lan_rule -p tcp -d 8.8.8.8 --dport 443 -j REJECT --reject-with tcp-reset

#iptables -t nat -A PREROUTING -p udp -m set --match-set bplanmac src -m set --match-set bplan_dns dst --dport 53 -j REDIRECT --to-ports 5336
#iptables -t nat -A PREROUTING -p tcp -m set --match-set bplanmac src -m set --match-set bplan_dns dst --dport 53 -j REDIRECT --to-ports 5336
iptables -t nat -A PREROUTING -m set --match-set bplanmac src -j RETURN
iptables -t nat -A PREROUTING -p udp -d 192.168.0.0/16 --dport 53 -j RETURN
iptables -t nat -A PREROUTING -p tcp -d 192.168.0.0/16 --dport 53 -j RETURN

#bropc
#iptables -t nat -A PREROUTING -p udp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
#iptables -t nat -A PREROUTING -p tcp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
#iptables -t nat -A PREROUTING -m set --match-set bropc src -j RETURN

iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53

#[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp -m set --match-set bplanmac src -m set --match-set bplan_dns6 dst --dport 53 -j REDIRECT --to-ports 5336
#[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp -m set --match-set bplanmac src -m set --match-set bplan_dns6 dst --dport 53 -j REDIRECT --to-ports 5336
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -m set --match-set bplanmac src -j RETURN
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp -d FC00::/7 --dport 53 -j RETURN
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp -d FC00::/7 --dport 53 -j RETURN

#bropc
#[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
#[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp -m set --match-set bropc src --dport 53 -j REDIRECT --to-ports 5337
#[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -m set --match-set bropc src -j RETURN

[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53
[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53
