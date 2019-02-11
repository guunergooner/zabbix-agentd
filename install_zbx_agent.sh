#!/bin/bash

function log () {
    echo $(date +"[%Y-%m-%d %H:%M:%S]") $@
}

if [ $# -lt 1 ]; then
    log "Usage: sh $0 host"
    exit
fi

host=$1
user=root

function install_zabbix_agentd () {
    log "mkdir"
    ssh -t ${user}@${host} "mkdir /home/admin/zabbix && chown -R admin:admin /home/admin/zabbix"

    log "copy file"
    scp ./* ${user}@${host}:/home/admin/zabbix

    log "exec install"
    ssh -t ${user}@${host} "cd /home/admin/zabbix && make install && sh restart.sh"
} 

install_zabbix_agentd
