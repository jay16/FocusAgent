#!/bin/bash

ENVIRONMENT=$1
APP_ROOT_PATH=$2
POOL_WAIT_PATH=$3

echo "app root path: ${APP_ROOT_PATH}"
while true
do
    if test -f ${APP_ROOT_PATH}/tmp/crontab.wait
    then
        echo "$(date +%Y-%m-%d_%H:%M:%S): be forced to skip."
    else
        if ["$(ls ${POOL_WAIT_PATH})" == ""];
        then
            echo "$(date +%Y-%m-%d_%H:%M:%S): idleness."
        else
            /bin/sh ${APP_ROOT_PATH}/lib/script/rake.sh ${APP_ROOT_PATH} ${ENVIRONMENT} 
        fi
    fi
    sleep 5
done
