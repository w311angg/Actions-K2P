#bropc
ipset -N bropc hash:mac 2>/dev/null
ipset flush bropc
#ipset add bropc <弟弟电脑mac> 2>/dev/null

#google one vpn bypass
ipset -N googlevpn_lan hash:mac 2>/dev/null
ipset flush googlevpn_lan
#ipset add googlevpn_lan <要使用googlevpn的设备mac> 2>/dev/null
