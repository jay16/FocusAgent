#!/bin/sh  
# 
PORT=3456
UNICORN=unicorn  
ENVIRONMENT=development
CONFIG_FILE=config/unicorn.rb  
  
case "$1" in  
    start)  
        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids
        bundle exec ${UNICORN} -c ${CONFIG_FILE} -p ${PORT} -E ${ENVIRONMENT} -D  
        ;;  
    stop)  
        kill -QUIT `cat tmp/pids/unicorn.pid`  
        ;;  
    restart|force-reload)  
        kill -USR2 `cat tmp/pids/unicorn.pid`  
        ;;  
    *)  
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2  
        exit 3  
        ;;  
esac  
