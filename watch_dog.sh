#!/bin/bash

USER=lijunjie
ENVIRONMENT=production
APP_ROOT_PATH=$(cat ./tmp/app_root_path)
POOL_DATA_PATH=$(cat ./tmp/pool_data_path)

case "$1" in
    start)
        nohup cd ${APP_ROOT_PATH} && /bin/sh lib/script/crontab.sh ${USER} ${ENVIRONMENT} ${APP_ROOT_PATH} ${POOL_DATA_PATH} >> log/crontab.log 2>&1 &
        echo $! > ${APP_ROOT_PATH}/tmp/pids/nohup.pid
        ;;
    stop)
        cd ${APP_ROOT_PATH} && kill -QUIT $(cat tmp/pids/nohup.pid)
        ;;
    restart|force-reload)
        cd ${APP_ROOT_PATH} && kill -USR2 $(cat tmp/pids/nohup.pid)
        ;;
    status)
        # ps result menu
        ps -ef | grep "PID" | grep -v "grep"
        # ps result list
        ps -ef | grep "crontab.sh" | grep -v "grep"
        ;;
    *)
        echo "Usage ./watch_dog.sh {start|stop|restart|status}"
        ;;
esac
