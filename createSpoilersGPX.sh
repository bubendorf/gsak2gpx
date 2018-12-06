#!/bin/bash

# Erzeugt eine GPX Datei der Caches mit gesetztem UserFlag
# Die GPX enthält keine Logs

export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh

export ENCODING=utf-8

function doit() {
# $1 Name der Kategorie
# $2 Basename der Output Datei
#  java $OPTS -jar $JAR --database $DB --categoryPath $CAT_PATH --categories $1 --outputPath - --encoding $ENCODING >$OUT_PATH/$2
  java $OPTS -jar $JAR --database  `$CYG2DOS $DB` --categoryPath $CAT_PATH --categories $1 --outputPath $OUT_PATH --filename $2 --encoding $ENCODING
}
export -f doit

doit UserFlagCachesNoLogs Spoilers
