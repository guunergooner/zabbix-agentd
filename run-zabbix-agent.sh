#!/bin/bash

#stop
pids=$(ps -ef | grep zabbix_agentd | grep -v 'grep' | awk '{print $2}' | xargs)
if [ ! -z "${pids}" ];then
    kill -9 ${pids}
fi

#start
/usr/sbin/zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf -f
