#!/bin/bash

app_root_path=$(cat ./tmp/app_root_path)
log_archived_path="./public/log_archived"
today=$(date '+%Y%m%d')
cd ${app_root_path}

echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') LogArchive start."
    test -d ${log_archived_path} || mkdir -p ${log_archived_path}

    if test -f ${log_archived_path}/${today}.tar.gz
    then
        echo -e "\t [danger] ${log_archived_path}/${today}.tar.gz already exist!"
        echo -e "\t please deal by hand, exit automatically."
        echo -e "$(date '+%Y-%m-%d %H:%M:%S') LogArchive completed.\n"
        exit 3
    fi

    cp -r ./log ./${today}
    echo -e "\t copy log files to tmp direcoty $(test $? -eq 0 && echo 'successfully' || echo 'failed')."
    tar -czf ${today}.tar.gz ./${today}/
    echo -e "\t compress tmp direcoty $(test $? -eq 0 && echo 'successfully' || echo 'failed')."
    mv ${today}.tar.gz ${log_archived_path}/
    echo -e "\t archive compress file $(test $? -eq 0 && echo 'successfully' || echo 'failed')."
    rm -fr ./${today}/
    echo -e "\t remove tmp direcoty $(test $? -eq 0 && echo 'successfully' || echo 'failed')."

    for file in ./log/*.log 
    do 
        if [[ "${file}" == "./log/logarc.log" ]];
        then
          echo -e "\t skip clear logarc.log"
        else
            true > ${file} 
        fi
    done
    echo -e "\t clear log files over."

echo -e "$(date '+%Y-%m-%d %H:%M:%S') LogArchive completed.\n"
