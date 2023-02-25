output_path='/var/dnsmasq.d/dnsmasq-ssrplus.d/010_quic_blocking.conf'
cat /etc/ssrplus/quic_blocking.list | sed '/^$/d' | sed "/.*/s/.*/ipset=\/&\/quic_blocking/" >$output_path
