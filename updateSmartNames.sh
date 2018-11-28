#!/bin/sh

echo Update SmartNames
. ./env.sh

LENGTH=24
WIDTH=206
JAR=/Users/mbu/src/SmartNames/build/libs/SmartNames-0.2-all.jar
OPTS="-Dorg.slf4j.simpleLogger.defaultLogLevel=debug"

java $OPTS -jar $JAR --database $DB --length $LENGTH --width $WIDTH --extension $SQL_EXT
