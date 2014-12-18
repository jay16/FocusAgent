#!/bin/bash

USER=webmail
ENVIRONMENT=production
APP_ROOT_PATH=$(cat ./tmp/app_root_path)
POOL_WAIT_PATH=$(cat ./tmp/pool_wait_path)

case "$1" in
    start)
        nohup cd ${APP_ROOT_PATH} && /bin/sh lib/script/crontab.sh ${ENVIRONMENT} ${APP_ROOT_PATH} ${POOL_WAIT_PATH} >> log/crontab.log 2>&1 &
        echo $! > ${APP_ROOT_PATH}/tmp/pids/nohup.pid
        ;;
    stop)
        # ps result menu
        ps -ef | grep "PID" | grep -v "grep"
        cd ${APP_ROOT_PATH} && ps -ef | grep $(cat tmp/pids/nohup.pid) | grep -v "grep"
        ;;
    restart|force-reload)
        cd ${APP_ROOT_PATH} && kill -USR2 $(cat tmp/pids/nohup.pid)
        ;;
    status)
        test -f ${APP_ROOT_PATH}/tmp/crontab.wait && echo "wait" || echo "active"

        # ps result menu
        ps -ef | grep "PID" | grep -v "grep"
        # ps result list
        ps -ef | grep "crontab.sh" | grep -v "grep"
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
