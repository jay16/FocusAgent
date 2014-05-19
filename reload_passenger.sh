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

cd $(pwd)
passenger stop -p 3456
passenger start -p 3456 --user $user -d

