#!/bin/sh  
# 
app_root_path="/home/work/focus_mail_agent/"
case "$1" in
    start)
        su - root -l -c "cd /home/work/focus_agent/ && passenger stop -p 3456"


        cd ${app_root_path}
        /bin/sh unicorn.sh start
        ;;
    stop)
        cd ${app_root_path}
        /bin/sh lib/script/unicorn.sh stop

        su - root -l -c "cd /home/work/focus_agent/ && passenger start -p 3456 --user webmail -d"
        ;;
    *)
        echo "Usage: $SCRIPTNAME {start|stop}"
        exit 3
        ;;
esac
