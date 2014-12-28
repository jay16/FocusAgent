#!/bin/sh  

port=$(test -z "$2" && echo "3456" || echo "$2")
environment=$(test -z "$3" && echo "production" || echo "$3")

echo -e "\tport: ${port} environment: ${environment}"
unicorn=unicorn  
config_file=./config/unicorn.rb  
pid_file=./tmp/pids/unicorn.pid
  
case "$1" in  
    start)  
        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids

        echo -e "\tstop nohup before start unicorn"
        /bin/sh nohup.sh stop

        echo -e "\tstart unicorn"
        bundle exec ${unicorn} -c ${config_file} -p ${port} -E ${environment} -D
        
        echo -e "\tstart nohup"
        /bin/sh nohup.sh start
        ;;  
    stop)  
        echo -e "\tstop unicorn"
        if test -f ${pid_file} 
        then
            kill -quit `cat ${pid_file}`  
        else
            echo -e "\t[WARNGIN]: unicorn.pid not exist."
        fi

        echo -e "\tstop nohup"
        /bin/sh nohup.sh stop
        ;;  
    restart|force-reload)  
        kill -usr2 `cat tmp/pids/unicorn.pid`  
        ;;  
    rake)
        echo -e "\trake task list:\n"
        echo -e "\tRACK_ENV=${environment} bundle exec rake agent:clear"
        echo -e "\tRACK_ENV=${environment} bundle exec rake agent:deploy"
        echo -e "\tRACK_ENV=${environment} bundle exec rake agent:check"
        echo -e "\tRACK_ENV=${environment} bundle exec rake agent:main"
        echo -e "\tRACK_ENV=${environment} bundle exec rake remote:deploy"
        ;;
    *)  
        echo "usage: $scriptname {start|stop|restart|force-reload|rake}" >&2  
        exit 3  
        ;;  
esac  
