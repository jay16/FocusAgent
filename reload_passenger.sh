#!/bin/bash
os=$(uname -s)
if [ $os = "Linux" ]
then 
  user="webmail" 
elif [ $os = "Darwin" ] 
then
  user="lijunjie" 
else
  user="webmail"
fi

port=3333
cd $(pwd)
passenger stop -p $port
passenger start -p $port --user $user -d

