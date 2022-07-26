#$ipt_n -A PSW $(comment "默认") -p tcp $(factor 85,86 "-m multiport --dport") $(dst $IPSET_SHUNTLIST) $(REDIRECT $TCP_REDIR_PORT)
#$ipt_n -A PSW $(comment "默认") -p tcp $(factor 85,86 "-m multiport --dport") $(dst $IPSET_BLACKLIST) $(REDIRECT $TCP_REDIR_PORT)
#$ipt_n -A PSW $(comment "默认") -p tcp $(factor 85,86 "-m multiport --dport") $(get_redirect_ipt $TCP_PROXY_MODE $TCP_REDIR_PORT)
