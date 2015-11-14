#!/bin/bash

#get main config
source "$1"

SMSHOST=smshost
SMSPORT=13013
SMSUSER=vasno
SMSPASS=vasno321
SMSFROM=$2
SMSTO=$3
SMSTEXT=$4

echo `date $LOGDATEFORMAT`" Sending SMS"
echo "conf=$1 from=$2 to=$3 text=$4"
ENCODED=$(echo -n "$SMSTEXT" | \
perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg');

URL="http://$SMSHOST:$SMSPORT/cgi-bin/sendsms?username=$SMSUSER&password=$SMSPASS&from=$SMSFROM&to=$SMSTO&text=$ENCODED$coding_params"

#pobranie strony
/usr/bin/wget \
--output-document=/dev/null \
--no-proxy \
$URL 

echo `date $LOGDATEFORMAT`" Sending SMS - done"
