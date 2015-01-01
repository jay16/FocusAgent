#!/bin/bash

APP_ROOT_PATH=$1
ENVIRONMENT=$2

/bin/bash -l -c "cd ${APP_ROOT_PATH} && RACK_ENV=${ENVIRONMENT} bundle exec rake agent:main" #>> ./log/crontab.log 2>1&
