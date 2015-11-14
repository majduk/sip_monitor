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

function sendEMAIL {
  source "$EMAILALERTPROFILE"
  $INSTALLDIR/bin/sendEmail.pl -f $SOURCE -t $TARGET $CCTARGET $BCCTARGET -u "$SUBJECT" -m "$MESSAGE" 
}

function sendSMS {
  source "$SMSALERTPROFILE"
  echo "SMS: $SOURCE $TARGET $MESSAGE"
  $INSTALLDIR/bin/sendsms.sh $CONFIGDIR/config.sh "$SOURCE" "$TARGET" "$MESSAGE"
}

function sendSTORE {
  $INSTALLDIR/bin/sendstore.sh "$CONFIGDIR"/config.sh "$SITECONFIG" "$ERROR" "$VERBOSEERROR" "$ALERTID"
}

function dispatchAltert {
      for alerttype in $ALERTTYPES; do
        echo "Sending alarm type" $alerttype "for $SITE_NAME"
        case $alerttype in
        "sms") sendSMS ;;
        "email")  sendEMAIL;;
        "store") sendSTORE ;;
        *) sendEMAIL
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