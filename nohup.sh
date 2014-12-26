#!/bin/bash

ENVIRONMENT=$(test -z "$2" && echo "production" || echo "$2")
APP_ROOT_PATH=$(cat ./tmp/app_root_path)
POOL_WAIT_PATH=$(cat ./tmp/pool_wait_path)

echo "environment:    ${ENVIRONMENT}"

case "$1" in
    start)
        if [[ $(ps -ef | grep "watch_dog.sh" | grep -v "grep" | wc -l) -eq 0 ]];
        then
            nohup /bin/sh ${APP_ROOT_PATH}/lib/script/watch_dog.sh ${ENVIRONMENT} ${APP_ROOT_PATH} ${POOL_WAIT_PATH} >> log/crontab.log 2>&1 &
            echo $! > ${APP_ROOT_PATH}/tmp/pids/nohup.pid
            test -f nohup.out && rm nohup.out
        else
            echo "WARNING: watch_dog.sh is already running."
        fi
        ;;
    stop)
         cd ${APP_ROOT_PATH} && test -f tmp/pids/nohup.pid && kill -9 $(cat tmp/pids/nohup.pid) 
         cd ${APP_ROOT_PATH} && test -f tmp/pids/watch_dog.pid && kill -9 $(cat tmp/pids/watch_dog.pid)
         cd ${APP_ROOT_PATH} && test -f tmp/pids/nohup.pid && rm tmp/pids/nohup.pid
         cd ${APP_ROOT_PATH} && test -f tmp/pids/watch_dog.pid && rm tmp/pids/watch_dog.pid
         cd ${APP_ROOT_PATH} && /bin/sh nohup.sh status
        ;;
    restart|force-reload)
        cd ${APP_ROOT_PATH} && kill -USR2 $(cat tmp/pids/nohup.pid)
        ;;
    status)
        # ps result menu
        ps -ef | grep "PID" | grep -v "grep"
        # ps result list
        ps -ef | grep "nohup.sh" | grep -v "grep"
        ps -ef | grep "watch_dog.sh" | grep -v "grep"
        ps -ef | grep "rake:agent:main" | grep -v "grep"

        test -f ${APP_ROOT_PATH}/tmp/crontab.wait && echo "\twait" || echo "\tactive"
        ;;
    active)
        cd ${APP_ROOT_PATH} && rm tmp/crontab.wait
        ;;
    wait)
        cd ${APP_ROOT_PATH} && touch tmp/crontab.wait
        ;;
    *)
        echo "Usage ./nohup.sh {start|stop|restart|status|active|wait}"
        ;;
esac
