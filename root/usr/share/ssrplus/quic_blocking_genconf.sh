for domain in $(cat "/etc/ssrplus/quic_blocking.list"); do
  if [[ "$domain" != "" ]]; then
    cat <<EOF >>/var/dnsmasq.d/dnsmasq-ssrplus.d/quic_blocking.conf
ipset=/$domain/quic_blocking
EOF
  fi
done
