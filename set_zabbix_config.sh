#!/bin/bash
modify_user=$(whoami)
modify_date=$(date +%Y-%m-%d)
monitor_host=10.88.128.40
hosts_conf=/etc/hosts
zabbix_agentd_conf=/etc/zabbix/zabbix_agentd.conf

sed -i "s/$(grep 'AllowRoot=' ${zabbix_agentd_conf})/AllowRoot=1/g" ${zabbix_agentd_conf}
sed -i "s/$(grep 'Server=' ${zabbix_agentd_conf} | grep -v '#')/Server=monitor.dev.rokid-inc.com/g" ${zabbix_agentd_conf}
sed -i "s/$(grep 'ServerActive=' ${zabbix_agentd_conf} | grep -v '#')/ServerActive=monitor.dev.rokid-inc.com/g" ${zabbix_agentd_conf}

echo -e "\n" >> ${hosts_conf} 
echo "#add by ${modify_user} ${modify_date}" >> ${hosts_conf}
echo "${monitor_host} monitor.dev.rokid-inc.com" >> ${hosts_conf}
