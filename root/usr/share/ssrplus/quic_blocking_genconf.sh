output_path='/var/dnsmasq.d/dnsmasq-ssrplus.d/quic_blocking.conf'
echo -n >$output_path
for domain in $(cat "/etc/ssrplus/quic_blocking.list"); do
  if [[ "$domain" != "" ]]; then
    cat <<EOF >>$output_path
ipset=/$domain/quic_blocking
EOF
  fi
done
