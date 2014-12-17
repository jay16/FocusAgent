#!/bin/bash

USER=lijunjie
APP_ROOT_PATH=$(cat ./tmp/app_root_path)
TODAY=$(date +%Y%m%d)

echo "app root path: ${APP_ROOT_PATH}"
exit 3
chown -R ${USER}:${USER} ${APP_ROOT_PATH}

while true
do
    su - ${USER} -l -c "cd ${APP_ROOT_PATH} && RACK_ENV=production bundle exec rake agent:main" >> ./log/crontab.${TODAY}.log 2>1&
    sleep 5
done
