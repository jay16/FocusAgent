#!/bin/sh  
# 

case "$1" in
    start)
        cd /home/work/focus_agent/
        passenger stop -p 3456


        cd /home/work/focus_mail_agent/
        sh lib/script/unicorn.sh start
        ;;
    stop)
        cd /home/work/focus_mail_agent/
        sh lib/script/unicorn.sh stop

        cd /home/work/focus_agent/
        passenger start -p 3456 --user webmail -d
        ;;
    *)
        echo "Usage: $SCRIPTNAME {start|stop}"
        exit 3
        ;;
esac
