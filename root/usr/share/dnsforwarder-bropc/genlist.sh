gfwlist_files='gfw_list.conf gfw_base.conf'
custom_files='black.list white.list chinadns_white.list chinadns_black.list'

case "$1" in
  "gfwlist")
    files=$gfwlist_files
    output_path='/etc/dnsforwarder-bropc/gfwlist.list'
    ;;
  "custom")
    files=$custom_files
    output_path='/var/etc/dnsforwarder-bropc/through_dnsmasq.list'
    ;;
  "all")
    "$0" gfwlist
    "$0" custom
    exit 0
    ;;
  *)
    echo 'add paramter "gfwlist", "custom" or "all"'
    exit 1
    ;;
esac

mkdir -p /var/etc/dnsforwarder-bropc/
echo -n >$output_path

for file in $files; do
  line_number_and_filename=$(wc -l "/etc/ssrplus/$file")
  finishing_number=0
  for domain in $(cat "/etc/ssrplus/$file"); do
    finishing_number=$(($finishing_number+1))
    if [[ "$domain" != "" ]]; then
      if [[ "$file" == "gfw_base.conf" ]] || [[ "$file" == "gfw_list.conf" ]]; then
        if [[ "$domain" =~ '^server=' ]]; then
          domain=$(echo $domain | sed 's/^server=\/\(.*\)\/.*$/\1/')
        else
          continue
        fi
      fi
      printf "$finishing_number/$line_number_and_filename\r"
      cat <<EOF >>$output_path
$domain
*.$domain
EOF
    fi
  done
done
echo
