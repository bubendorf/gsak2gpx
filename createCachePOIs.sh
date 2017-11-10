#!/bin/sh
OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH="/Users/mbu/src/gsak2gpx/categories/cachepoi /Users/mbu/src/gsak2gpx/categories/include"
OUT_PATH=/Users/mbu/src/gsak2gpx/output/cachepoi
TASKS=4
CATEGORIES=Traditional,Unknown,Multi,VirtualCache,Letterbox,Earthcache,Wherigo,Webcam

java $OPTS -jar target/gsak2gpx-1.0-SNAPSHOT.jar --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $OUT_PATH --tasks $TASKS

