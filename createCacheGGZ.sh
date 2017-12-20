#!/bin/bash
export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh


export ENCODING=utf-8
export CACHES_PER_GPX=300
export MAX_SIZE=2985000

function doit() {
# $1 Name der Kategorie und der GGZ Datei
  java $OPTS -jar target/gsak2gpx-1.1.jar --database $DB --categoryPath $CAT_PATH --categories $1 --outputPath - --encoding $ENCODING | java $OPTS -cp target/gsak2gpx-1.1.jar ch.bubendorf.ggzgen.GGZGenKt --input - --output $OUT_PATH/$1.ggz --encoding $ENCODING --count $CACHES_PER_GPX --size $MAX_SIZE
}
export -f doit

# parallel --delay 1 -j $TASKS -u doit ::: E8_Nord E7_Nord E5_6 E9_10 E7_8_Sued
parallel --delay 1 -j $TASKS -u doit ::: UserFlagOst UserFlagWest
