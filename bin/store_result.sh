#!/bin/bash

#get main config
source "$1"

#get site config
source "$2"

file=$TESTRESULT

echo `date $LOGDATEFORMAT`" Import data from $file"

echo "LOAD DATA LOCAL INFILE '"$file"' IGNORE INTO TABLE \`"$SQLDATABASE"\`.\`"$SQLTABLE"\` FIELDS TERMINATED BY ';';" > $SQLFILE
/usr/bin/mysql -f -h $SQLHOST -u$SQLUSER -p$SQLPASSWORD $SQLDATABASE < $SQLFILE

echo `date $LOGDATEFORMAT`" Import data from $file - done"
