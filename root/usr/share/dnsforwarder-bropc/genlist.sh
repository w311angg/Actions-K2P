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
    set -e
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
  if [[ "$file" == "gfw_base.conf" ]] || [[ "$file" == "gfw_list.conf" ]]; then
    grep '^server=' /etc/ssrplus/$file | sed 's/^server=\/\(.*\)\/.*$/\1\n*.\1/g' > /etc/ssrplus/$file
  else
    cat /etc/ssrplus/$file | sed '/^$/d' | sed "/.*/s/.*/&\n*.&/"
  fi
done
