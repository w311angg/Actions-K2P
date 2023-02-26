#更改时也要更改diy脚本预处理部分，文件后缀为.conf的按dnsmasq配置格式处理
gfwlist_files='gfw_list.conf gfw_base.conf china.list'
custom_files='black.list white.list chinadns_white.list chinadns_black.list quic_blocking.list'

case "$1" in
  "gfwlist")
    files=$gfwlist_files
    output_path='/var/etc/dnsforwarder-bropc/gfwlist.list'
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
  if [[ "$file" ~= ".conf$" ]]; then
    grep '^server=' /etc/ssrplus/$file | sed 's/^server=\/\(.*\)\/.*$/\1\n*.\1/g' >>$output_path
  else
    cat /etc/ssrplus/$file | sed '/^$/d' | sed "/.*/s/.*/&\n*.&/" >>$output_path
  fi
done

cat $output_path | sort | uniq >$output_path
