#!/bin/bash

APP_ROOT_PATH=$(cat ./tmp/app_root_path)
if [[ $(crontab -l | grep "${APP_ROOT_PATH}" | wc -l ) -gt 0 ]];
then
else
fi

