#!/bin/bash

#get main config
source "$1"

#get site config
source "$2"

echo `date $LOGDATEFORMAT`" Connection to site $TESTURL"

#pobranie strony
/usr/bin/wget --cookies=on --save-cookies "$COOKIE_FILE" \
--header="X-WAP-MSISDN: $TEST_MSISDN" --header="User-IP: $TEST_IP" --user-agent="$TEST_USER_AGENT" \
--output-document=$OUTPUTDOCUMENT \
--output-file=$OUTPUTLOG \
$TESTURL 

echo `date $LOGDATEFORMAT`" Connection to site $TESTURL - done"