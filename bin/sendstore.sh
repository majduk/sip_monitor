#!/bin/bash

#get main config
source "$1"

#Default Alert Profiles
source $ALERTCONFIG

#get site config
source "$2"

#get own config
source "$STOREALERTPROFILE"

#ERROR
ERROR="$3"

#VERBOSEERROR
VERBOSEERROR="$4"

#VERBOSEERROR
ALERT_ID="$5"

echo `date $LOGDATEFORMAT`" Storing alert $ALERT_ID for $SITE_NAME ERROR=$ERROR $VERBOSEERROR"

cp "$OUTPUTDOCUMENT" "$STOREDIR"/"$ALERT_ID"_output.html
cp "$OUTPUTLOG" "$STOREDIR"/"$ALERT_ID"_wget.log
cp "$TESTRESULT" "$STOREDIR"/"$ALERT_ID"_check.result

echo `date $LOGDATEFORMAT`" Storing alert $ALERT_ID for $SITE_NAME ERROR=$ERROR $VERBOSEERROR - done"

