#!/bin/bash

function log () {
    echo $(date +"[%Y-%m-%d %H:%M:%S]") $@
}

if [ $# -lt 3 ]; then
    log "Usage: $0 user_name time_zone image_name"
    exit
fi

user_name=$1
time_zone=$2
image_name=$3
server_addr="monitor.com"

docker build . -t ${image_name} \
    --build-arg USER_NAME=${user_name} \
    --build-arg TIMEZONE=${time_zone} \
    --build-arg SERVER_ADDR=${server_addr}
