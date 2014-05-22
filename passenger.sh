#!/bin/bash

port=3333;
user="webmail";
action="$1";

if [ ! -n "$1" ]; 
then
  action="restart"
fi

cd $(pwd)

case $action in
    stop)
        passenger stop -p $port
    ;;
    start)
        passenger start -p $port --user $user -d
    ;; 
    restart)
        passenger stop -p $port
        passenger start -p $port --user $user -d
    ;;
    *)
       echo "unkown action: ${action}"
   ;;
esac




