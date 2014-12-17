#!/bin/bash
USER=$1
APP_ROOT_PATH=$2
ENVIRONMENT=$3

su - ${USER} -l -c "cd ${APP_ROOT_PATH} && RACK_ENV=${ENVIRONMENT} bundle exec rake agent:main" >> ./log/crontab.log 2>1&
