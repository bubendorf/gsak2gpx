#!/bin/sh
OPTS="-Xmx6G -Dorg.slf4j.simpleLogger.showDateTime=true"
java $OPTS -jar target/gsak2gpx-1.0-SNAPSHOT.jar --database /Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3 --categoryPath /Users/mbu/src/gsak2gpx/categories --categories test --outputPath /Users/mbu/src/gsak2gpx/output --tasks 1
