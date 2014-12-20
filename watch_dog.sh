#!/bin/bash

if test -z "$2"
then
    ENVIRONMENT="production"
else
    ENVIRONMENT="$2"
fi
APP_ROOT_PATH=$(cat ./tmp/app_root_path)
POOL_WAIT_PATH=$(cat ./tmp/pool_wait_path)

echo "environment: ${ENVIRONMENT}"

case "$1" in
    start)
        nohup cd ${APP_ROOT_PATH} && /bin/sh lib/script/crontab.sh ${ENVIRONMENT} ${APP_ROOT_PATH} ${POOL_WAIT_PATH} >> log/crontab.log &
        echo $! > ${APP_ROOT_PATH}/tmp/pids/nohup.pid
        ;;
    stop)
         cd ${APP_ROOT_PATH} && kill -9 $(cat tmp/pids/nohup.pid) && rm tmp/pids/nohup.pid
         cd ${APP_ROOT_PATH} && kill -9 $(cat tmp/pids/crontab.pid) && rm tmp/pids/crontab.pid
         cd ${APP_ROOT_PATH} && /bin/sh watch_dog.sh status
        ;;
    restart|force-reload)
        cd ${APP_ROOT_PATH} && kill -USR2 $(cat tmp/pids/nohup.pid)
        ;;
    status)
        # ps result menu
        ps -ef | grep "PID" | grep -v "grep"
        # ps result list
        ps -ef | grep "watch_dog.sh" | grep -v "grep"
        ps -ef | grep "crontab.sh" | grep -v "grep"
        ps -ef | grep "rake:agent:main" | grep -v "grep"

        test -f ${APP_ROOT_PATH}/tmp/crontab.wait && echo "wait" || echo "active"
        ;;
    active)
         cd ${APP_ROOT_PATH} && rm tmp/crontab.wait
         ;;
    wait)
         cd ${APP_ROOT_PATH} && touch tmp/crontab.wait
         ;;
    *)
        echo "Usage ./watch_dog.sh {start|stop|restart|status|active|wait}"
        ;;
esac
