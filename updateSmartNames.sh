#!/bin/bash

# Ins Verzeichnis des Scrips wechseln
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
. ./env.sh

# Angaben für den SmartName Algorithmus
LENGTH=24
WIDTH=206
JAR=../SmartNames/build/libs/SmartNames-0.3.3-all.jar
OPTS="-Dorg.slf4j.simpleLogger.defaultLogLevel=debug"

echo "Update SmartNames default DB"
# SmartNames setzen
echo $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB` --length $LENGTH --width $WIDTH --extension `$CYG2DOS $SQL_EXT`
$JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB` --length $LENGTH --width $WIDTH --extension `$CYG2DOS $SQL_EXT` 2>&1 | tee -a log/upateSmartNames.log

echo "Das AverageFoundsPerYear, FavRatio und Child Waypoints aktualisieren"
# Das AverageFoundsPerYear, FavRatio und Child Waypoints aktualisieren
$SQLITE $DB <<SQLCodeSQLCode
.output /dev/null
PRAGMA journal_mode = MEMORY;
PRAGMA synchronous = OFF;
PRAGMA temp_store = MEMORY;
PRAGMA cache_size = 262144;
PRAGMA threads = 4;
.output

.print 'Remove all ?? from the Logs'
update LogMemo set lText=replace(lText, '??', '') where lText like '%??%';

.print 'Update AvgLogsPerYear'
update Custom
set AvgLogsPerYear = (select round(count(*) / (max(14.0, julianday('now') - julianday(min(lDate))) + 1.0) * 365.24, 1) from Logs where lType = 'Found it' and lParent = cCode )
where exists(select lParent from Logs where lType = 'Found it' and lParent = cCode);

.print 'Update FavRatio'
update Custom set FavRatio = Round(100.0 * (select FavPoints From Caches where Code = cCode) / (select count(*) from Logs where lType = 'Found it' and lParent = cCode ), 1)
where exists(select lParent from Logs where lType = 'Found it' and lParent = cCode);

.print 'Update Waypoints'
update Waypoints set cName = substr(cName, length(cParent)+2) where cName like cParent || '%';

SQLCodeSQLCode

if [ ! -z $DB2 -a -f $DB2 ]
then
  echo "Update SmartNames alternative DB"
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB2` --length $LENGTH --width $WIDTH --extension `$CYG2DOS $SQL_EXT` 2>&1 | tee -a log/upateSmartNames.log
fi

echo "Update SmartNames found DB"
$JAVA $OPTS -jar $JAR --database `$CYG2DOS $FOUND_DB` --length $LENGTH --width $WIDTH --extension `$CYG2DOS $SQL_EXT` 2>&1 | tee -a log/upateSmartNames.log
