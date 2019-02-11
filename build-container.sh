#!/bin/bash

function log () {
    echo $(date +"[%Y-%m-%d %H:%M:%S]") $@
}

if [ $# -lt 3 ]; then
    log "Usage: $0 user_name image_name container_name"
    exit
fi

user_name=$1
image_name=$2
container_name=$3

docker run -itd \
    --runtime=nvidia \
    --name=${container_name} \
    --network="host" \
    --volume=/var/log/zabbix:/var/log/zabbix \
    ${image_name} \
    sudo /bin/bash /home/${user_name}/zabbix/run-zabbix-agent.sh
