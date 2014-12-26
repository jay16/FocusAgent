#!/bin/sh  
# 

PORT=$(test -z "$2" && echo "3456" || echo "$2")
ENVIRONMENT=$(test -z "$3" && echo "production" || echo "$3")

echo "port: ${PORT} environment: ${ENVIRONMENT}"
UNICORN=unicorn  
CONFIG_FILE=config/unicorn.rb  
  
case "$1" in  
    start)  
        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids

        echo "stop nohup"
        /bin/sh nohup.sh stop

        echo "start unicorn"
        bundle exec ${UNICORN} -c ${CONFIG_FILE} -p ${PORT} -E ${ENVIRONMENT} -D  
        
        echo "start nohup"
        /bin/sh nohup.sh start
        ;;  
    stop)  
        echo "stop unicorn"
        if test -f tmp/pids/unicorn.pid 
        then
            kill -QUIT `cat tmp/pids/unicorn.pid`  
        else
            echo "[WARNGIN]: unicorn.pid not exist."
        fi

        echo "stop nohup"
        /bin/sh nohup.sh stop
        ;;  
    restart|force-reload)  
        kill -USR2 `cat tmp/pids/unicorn.pid`  
        ;;  
    rake)
        echo "rake task list:\n"
        echo "RACK_ENV=${ENVIRONMENT} bundle exec rake agent:clear"
        echo "RACK_ENV=${ENVIRONMENT} bundle exec rake agent:deploy"
        echo "RACK_ENV=${ENVIRONMENT} bundle exec rake agent:check"
        echo "RACK_ENV=${ENVIRONMENT} bundle exec rake agent:main"
        echo "RACK_ENV=${ENVIRONMENT} bundle exec rake remote:deploy"
        ;;
    *)  
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload|rake}" >&2  
        exit 3  
        ;;  
esac  
