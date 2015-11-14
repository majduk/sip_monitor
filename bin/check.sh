#!/bin/bash

#get main config
source "$1"

#get site config
source "$2"

#error configuration
source "$ERRORCONFIG"

echo `date $LOGDATEFORMAT`" Verifying results"

RC=0
#sprawdzenie kodu odpowiedzi serwera
HTTPReturnCode=`grep 'awaiting response' $OUTPUTLOG | awk '{print $6}'`
HTTPReturnCode=`echo $HTTPReturnCode | sed -e 's/ /_/g'`
#HTTPReturnCode=410
echo "HTTP Error code "$HTTPReturnCode
eval RC=\$HTTPERROR$HTTPReturnCode
if [ "$RC" = "" ]; then
  echo "No http error mapping found, using default $HTTPERRORDEFAULT"
  RC=$HTTPERRORDEFAULT
fi
if [ "$RC" != "0" ]; then
  echo "HTTP Error detected"
  echo "$NOW;$RC;$HTTPReturnCode;0;0;0;0" > "$TESTRESULT"
  echo `date $LOGDATEFORMAT`" Verifying results - done"
  exit $RC 
fi

#sprawdzenie prêdkoci downloadu
HTTPDownloadSpeed=`grep 'saved' $OUTPUTLOG | awk '{print $3 $4}' | sed -n 's/[()B/s]//gp'` 
echo "HTTP Download Speed "$HTTPDownloadSpeed

#ile procent diff-a jest rozne od wzorca 
resultsize=`ls -la $OUTPUTDOCUMENT | awk '{print $5}'`
patternsize=`ls -la $PATTERNFILE | awk '{print $5}'`
echo "Received "$resultsize "bytes"
echo "Expected "$patternsize "bytes"
ratio=`echo $resultsize/$patternsize|bc -l`
echo "Ratio $ratio"
exceeded=`bc << EOF
$ratio < $RATIO_MIN || $ratio > $RATIO_MAX
EOF`
echo "Ratio exceeded=$exceeded"
if [ "$exceeded" != "0" ]; then
  echo "HTTP Size not match"
  RC=$CONTENTERRORSIZE 
fi

echo "$NOW;$RC;$HTTPReturnCode;$resultsize;$patternsize;$exceeded;$HTTPDownloadSpeed" > "$TESTRESULT"
echo `date $LOGDATEFORMAT`" Verifying results - done ($RC)"
exit $RC 
