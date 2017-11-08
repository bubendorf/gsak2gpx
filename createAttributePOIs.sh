#!/bin/sh
OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH=/Users/mbu/src/gsak2gpx/categories
OUT_PATH=/Users/mbu/src/gsak2gpx/output/gpigen
TASKS=4
CATEGORIES=Favorites,Parking,Virtual,Reference,Trailhead,Physical,Original,Final,Disabled,Corrected,Terrain5

java $OPTS -jar target/gsak2gpx-1.0-SNAPSHOT.jar --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $OUT_PATH --tasks $TASKS

# gpsbabel -i gpx -f $OUT_PATH/Favorites.gpx -i gpx -f $OUT_PATH/Disabled.gpx -i gpx -f $OUT_PATH/Corrected.gpx -i gpx -f $OUT_PATH/Terrain5.gpx  -o garmin_gpi -F $OUT_PATH/attributes.gpi
