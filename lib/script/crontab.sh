#!/bin/bash
while true
do
     /bin/bash -l -c "cd ~/Code/work/focus_mail_agent && RACK_ENV=production bundle exec rake agent:main"
     sleep 5
done
