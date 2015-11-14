#!/bin/bash

#get main config
source "$1"

#get site config
source "$2"

echo `date $LOGDATEFORMAT`" Connection to site $sip_url"

if [ "$SIPP_MODE" == "FG" ];then
        SIPP_MODE=""
else
        SIPP_MODE="-bg"
fi

case "$TRANSPORT_MODE" in
  "UDP_MONO") TRANSPORT_MODE="-t u1";;
  "TCP_MONO") TRANSPORT_MODE="-t t1";;
  "UDP_MULTI") TRANSPORT_MODE="-t un";;
  "UDP_MULTI") TRANSPORT_MODE="-t tn";;
  *) TRANSPORT_MODE=""
esac

/usr/local/bin/sipp $SIPP_MODE $TRANSPORT_MODE -nostdin -recv_timeout $recv_timeout -trace_msg -message_file $MESSAGE_FILE -trace_err -error_file $ERROR_FILE -l $simultaneus -r $rate -rp $rp -rate_increase $rate_increase -fd 5s -m $calls_no -s $sip_service -sf $SCENARIO -inf $USERS_FILE -mp $media_port_base -mi $media_ip -i $local_ip $sip_url
rc=$?
if [ "$rc" == 99 ];then
  sleep $test_time_sec
else
  echo "SIPP_EXECUTION_ERR" > $ERROR_FILE  
fi

echo `date $LOGDATEFORMAT`" Connection to site $sip_url - done"
