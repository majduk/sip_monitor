#!/bin/bash

#get main config
source "$1"

#Defailt Alert Profiles
source $ALERTCONFIG

#get site config
SITECONFIG="$2"
source "$SITECONFIG"

#ERROR
ERROR=$3

#DESCRIPTION
source $ERRORCONFIG

eval VERBOSEERROR=\$ERROR$ERROR
if [ "$VERBOSEERROR" = "" ]; then
  VERBOSEERROR=$ERROREDEFAULT
fi

ALERTID=$NOW


function sendMessage {
  source "$1"
  
  for profile in $SENDPROFILES; do
    for param in $SENDPARAMS; do
      eval param_"$profile"_"$param"=\$"$profile""_""$param";
      eval val=\$param_"$profile"_"$param";
      if [ "$val" = "" ]; then
        eval param_"$profile"_"$param"=\$"DEFAULT_$param";
      fi
      eval $param=\$param_"$profile"_"$param";
      #eval dbg=\$"$param";
      #echo "$profile $param $dbg";
    done      

    send_flag=0;
    for e in $SENDERRORS; do
      tmp=`expr match $ERROR $e`
      if [ "$tmp" != "0" ]; then      
        send_flag=1;
      fi 
    done 
    if [ "$send_flag" = "1" ]; then
        echo "EXECUTING $SENDCOMMAND"
        eval "$SENDCOMMAND";        
    fi
  
  done  
}

function dispatchAltert {
      for alerttype in $ALERTTYPES; do
        echo "Sending alarm type" $alerttype "for $SITE_NAME"
        case $alerttype in
        "sms") sendMessage "$SMSALERTPROFILE";;
        "email")  sendMessage "$EMAILALERTPROFILE";;
        "store") sendMessage "$STOREALERTPROFILE";;
        *) sendMessage "$EMAILALERTPROFILE";;
      esac
      
      done
}
function isForceResend {
  lastTime=$1
  lastState=$2
  currState=$3
  return 0
}

echo `date $LOGDATEFORMAT`" Checking alerts for $SITE_NAME (with error=$ERROR)"
state_transition=0;
#1) Is state changed?
# a) get last alert
read lastAlertTimestamp lastErrorState < "$ALERTFILE" 
echo "Last alerting state:" $lastAlertTimestamp $lastErrorState
# b) compare -> if state changed, set flag
isForceResend $lastAlertTimestamp $lastErrorState $ERROR
force=$?
if [ "$ERROR" != "$lastErrorState" ] || [ "$force" != "0" ]; then
    # c) store to file
    echo $NOW $ERROR > "$ALERTFILE" 
    state_transition=1
    echo "Alerting state changed to $ERROR"
fi 
#2) if flag -> notify
if [ "$state_transition" != 0 ]; then
   dispatchAltert;
fi 

echo `date $LOGDATEFORMAT`" Checking alerts for $SITE_NAME - done"