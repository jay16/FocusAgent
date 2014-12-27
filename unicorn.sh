#!/bin/sh  

port=$(test -z "$2" && echo "3456" || echo "$2")
environment=$(test -z "$3" && echo "production" || echo "$3")

echo "\tport: ${port} environment: ${environment}"
unicorn=unicorn  
config_file=./config/unicorn.rb  
pid_file=./tmp/pids/unicorn.pid
  
case "$1" in  
    start)  
        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids

        echo "\tstop nohup before start unicorn"
        /bin/sh nohup.sh stop

        echo "\tstart unicorn"
        bundle exec ${unicorn} -c ${config_file} -p ${port} -E ${environment} -D
        
        echo "\tstart nohup"
        /bin/sh nohup.sh start
        ;;  
    stop)  
        echo "\tstop unicorn"
        if test -f ${pid_file} 
        then
            kill -quit `cat ${pid_file}`  
        else
            echo "\t[WARNGIN]: unicorn.pid not exist."
        fi

        echo "\tstop nohup"
        /bin/sh nohup.sh stop
        ;;  
    restart|force-reload)  
        kill -usr2 `cat tmp/pids/unicorn.pid`  
        ;;  
    rake)
        echo "\trake task list:\n"
        echo "\tRACK_ENV=${environment} bundle exec rake agent:clear"
        echo "\tRACK_ENV=${environment} bundle exec rake agent:deploy"
        echo "\tRACK_ENV=${environment} bundle exec rake agent:check"
        echo "\tRACK_ENV=${environment} bundle exec rake agent:main"
        echo "\tRACK_ENV=${environment} bundle exec rake remote:deploy"
        ;;
    *)  
        echo "usage: $scriptname {start|stop|restart|force-reload|rake}" >&2  
        exit 3  
        ;;  
esac  
