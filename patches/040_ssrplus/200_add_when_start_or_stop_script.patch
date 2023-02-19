--- feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr	2023-02-19 11:40:17.300236408 +0800
+++ feeds/helloworld/luci-app-ssr-plus/root/etc/init.d/shadowsocksr	2023-02-19 11:43:08.210236343 +0800
@@ -893,6 +893,7 @@ start_rules() {
 }
 
 start() {
+	/usr/share/shadowsocksr/when_start.sh
 	set_lock
 	echolog "----------start------------"
 	mkdir -p /var/run /var/lock /var/log /tmp/dnsmasq.d $TMP_BIN_PATH $TMP_DNSMASQ_PATH
@@ -934,6 +935,7 @@ boot() {
 }
 
 stop() {
+	/usr/share/shadowsocksr/when_stop.sh
 	unlock
 	set_lock
 	/usr/bin/ssr-rules -f
