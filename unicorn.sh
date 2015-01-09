#!/bin/sh  

port=$(test -z "$2" && echo "3456" || echo "$2")
environment=$(test -z "$3" && echo "production" || echo "$3")

unicorn=unicorn  
config_file=./config/unicorn.rb  
pid_file=./tmp/pids/unicorn.pid
app_root_path=$(cat ./tmp/app_root_path)
  
case "$1" in  
    start)  
        test -d log || mkdir log
        test -d tmp || mkdir -p tmp/pids

        cd ${app_root_path}
        echo -e "\t## start unicorn"
        echo -e "\t port: ${port}"
        echo -e "\t environment: ${environment}"
        echo -e "\t $(ruby -v)"

        bundle exec ${unicorn} -c ${config_file} -p ${port} -E ${environment} -D
        echo -e "\t unicorn start $(test $? -eq 0 && echo "successfully" || echo "failed")."

        echo -e "\t## start nohup"
        /bin/sh nohup.sh start
        ;;  
    stop)  
        echo -e "\t## stop unicorn"
        if test -f ${pid_file} 
        then
            kill -quit `cat ${pid_file}`  
            echo -e "\t unicorn stop $(test $? -eq 0 && echo "successfully" || echo "failed")."
        else
            echo -e "\t unicorn stop failed - process not exist."
        fi

        echo -e "\t## stop nohup"
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
