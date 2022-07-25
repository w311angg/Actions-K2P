#iptables -t nat -w -A PSW -m comment --comment '默认' -p tcp -m multiport --dport 85,86 -m set --match-set shuntlist dst -j REDIRECT --to-ports 1041
#iptables -t nat -w -A PSW -m comment --comment '默认' -p tcp -m multiport --dport 85,86 -m set --match-set blacklist dst -j REDIRECT --to-ports 1041
#iptables -t nat -w -A PSW -m comment --comment '默认' -p tcp -m multiport --dport 85,86 -m set ! --match-set chnroute dst -j REDIRECT --to-ports 1041
