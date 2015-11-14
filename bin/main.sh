#!/bin/bash

CONFIGDIR="/root/pvb_monitor/etc"
CONFIGFILE=$CONFIGDIR/"config.sh"
source "$CONFIGFILE";

/usr/sbin/logrotate --state $LOGDIR/logrotate.status $CONFIGDIR/"logrotate.cfg"  >> $LOGDIR/$LOGFILE 2>&1

echo `date $LOGDATEFORMAT`" +++++++++++++++++++++++ RUN START +++++++++++++++++++++++" >> $LOGDIR/$LOGFILE 2>&1

for s in $(cat $SITELIST); do
    echo "Checking site $s" >> $LOGDIR/$LOGFILE 2>&1
    site=$CONFIGDIR/$s
    $INSTALLDIR/bin/sipp.sh "$CONFIGFILE" "$site"  >> $LOGDIR/$LOGFILE 2>&1 
    $INSTALLDIR/bin/sipp_check.sh "$CONFIGFILE" "$site"  >> $LOGDIR/$LOGFILE 2>&1 
    ERROR=$?
    #analyze results
    if [ "$ERROR" != "0" ];then
      echo `date $LOGDATEFORMAT`" ERROR $ERROR DETECTED AT $site" >> $LOGDIR/$LOGFILE 2>&1
    fi
    #$INSTALLDIR/bin/store_result.sh "$CONFIGFILE" "$site"  >> $LOGDIR/$LOGFILE 2>&1
    $INSTALLDIR/bin/alert_dispatch.sh "$CONFIGFILE" "$site" $ERROR >> $LOGDIR/$LOGFILE 2>&1
done

echo `date $LOGDATEFORMAT`" +++++++++++++++++++++++ RUN   END +++++++++++++++++++++++"  >> $LOGDIR/$LOGFILE 2>&1
