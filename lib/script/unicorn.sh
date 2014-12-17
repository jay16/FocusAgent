#!/bin/sh  
# 
PORT=4000
UNICORN=unicorn  
ENVIRONMENT=development
CONFIG_FILE=config/unicorn.rb  
  
case "$1" in  
    start)  
        test -d log || mkdir log
        test -d shared || mkdir -p ./{log,shared/pids}
        bundle exec ${UNICORN} -c ${CONFIG_FILE} -p ${PORT} -E ${ENVIRONMENT} -D  
        ;;  
    stop)  
        kill -QUIT `cat shared/pids/unicorn.pid`  
        ;;  
    restart|force-reload)  
        kill -USR2 `cat shared/pids/unicorn.pid`  
        ;;  
    *)  
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2  
        exit 3  
        ;;  
esac  
