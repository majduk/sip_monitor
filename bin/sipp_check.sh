#!/bin/bash

#get main config
source "$1"

#get site config
source "$2"

echo `date $LOGDATEFORMAT`" Verifying results"

RC=0
#sprawdzenie kodu odpowiedzi serwera
if [ -f "$ERROR_FILE" ];then
  cat "$ERROR_FILE" 
  RC=1
  rm -f "$ERROR_FILE"
  rm -f "$MESSAGE_FILE"
else
  if [ -f "$MESSAGE_FILE" ];then
    rm -f "$MESSAGE_FILE"
  fi
fi
echo `date $LOGDATEFORMAT`" Verifying results - done ($RC)"
exit $RC 
