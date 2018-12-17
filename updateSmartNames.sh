#!/bin/sh

echo Update SmartNames
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
. ./env.sh

LENGTH=24
WIDTH=206
JAR=../SmartNames/build/libs/SmartNames-0.3-all.jar
OPTS="-Dorg.slf4j.simpleLogger.defaultLogLevel=debug"

java $OPTS -jar $JAR --database `$CYG2DOS $DB` --length $LENGTH --width $WIDTH --extension `$CYG2DOS $SQL_EXT` 2>&1 | tee -a log/upateSmartNames.log
