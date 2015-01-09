#!/bin/bash

app_root_path=$(cat ./tmp/app_root_path)
unicorn_pid_file=./tmp/pids/unicorn.pid
watchdog_pid_file=./tmp/pids/watch_dog.pid
logfile=./log/chkdog.log
badfile=./log/chkdog.bad.log
tmpfile=./tmp/.chkdog.bad.log

#################################
# check last ChkDog status start
# redirect to chkdog.bad.log when not everything is ok
last_start_num=$(grep -n "ChkDog start" ${logfile} | tail -1 | cut -d ":" -f 1)
row_num=$(cat log/chkdog.log  | wc -l)
let content_num=row_num-last_start_num+2
tail -n ${content_num} ${logfile} > ${tmpfile} 2>&1
if [[ $(cat ${tmpfile} | grep "everything" | wc -l) -eq 0 ]];
then
    cat ${tmpfile} >> ${badfile} 2>&1
fi
# check last ChkDog status end
#################################

whether_process_restart() {
    pid_file=$1
    pid_name=$2
    process_status=0
    if test -f "${pid_file}"
    then
        pid_value=$(cat ${pid_file})
        ps -p ${pid_value} > /dev/null
        if [[ $? -eq 0 ]]; 
        then
            echo -e "\t${pid_name} pid ${pid_value} is running."
        else
            echo -e "\t${pid_name} pid ${pid_value} not found."
            process_status=1
        fi
    else
        echo -e "\t${pid_name} ${pid_file} not exist!"
        process_status=1
    fi
    return ${process_status};
}

echo "$(date '+%Y-%m-%d %H:%M:%S') ChkDog start."
cd ${app_root_path}
whether_process_restart ${unicorn_pid_file}  "[unicorn] - "
unicorn_status=$?
whether_process_restart ${watchdog_pid_file} "[nohup]   - "
watchdog_status=$?

if [[ ${unicorn_status} -eq 1 || ${watchdog_status} -eq 1 ]]; 
then
    echo -e "\t=> env settings"
    source ~/.bashrc       > /dev/null 2>&1
    source ~/.bash_profile > /dev/null 2>&1
    export LANG=zh_CN.UTF-8
    echo -e "\t LANG=$LANG"
    echo -e "\t=> [restart] for above reason."
    cd ${app_root_path}
    /bin/sh unicorn.sh stop
    /bin/sh unicorn.sh start
else
    echo -e "\t=> everything is [ok]"
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') ChkDog completed."
echo ""

