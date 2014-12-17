#!/bin/bash

USER=$1
ENVIRONMENT=$2
APP_ROOT_PATH=$3
POOL_DATA_PATH=$4

echo "app root path: ${APP_ROOT_PATH}"
while true
do
    if test -f ${APP_ROOT_PATH}/tmp/crontab.exit 
    then
        echo "$(date +%Y-%m-%d_%H:%M:%S): be forced to skip."
    else
        if ["$(ls ${POOL_DATA_PATH})" = ""];
        then
            echo "$(date +%Y-%m-%d_%H:%M:%S): idleness."
        else
            /bin/sh ${APP_ROOT_PATH}/lib/script/rake.sh ${USER} ${APP_ROOT_PATH} ${ENVIRONMENT} 
        fi
    fi
    sleep 5
done
