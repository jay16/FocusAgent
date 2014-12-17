#!/bin/bash

USER=lijunjie
APP_PATH=$(pwd)

chown -R ${USER}:${USER} ./
while true
do
    pwd
    su - ${USER} -l -c "cd ${APP_PATH} && RACK_ENV=production bundle exec rake agent:main" #>> ./log/crontab.log 2>1&
    sleep 5
done
