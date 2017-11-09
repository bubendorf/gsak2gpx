#!/bin/sh
OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH=/Users/mbu/src/gsak2gpx/categories
OUT_PATH=/Users/mbu/src/gsak2gpx/output
TASKS=1
CATEGORIES=ActiveCaches
GGZ=ActiveCaches
ENCODING=utf-8
CACHES_PER_GPX=250

java $OPTS -jar target/gsak2gpx-1.0-SNAPSHOT.jar --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $OUT_PATH --tasks $TASKS --encoding $ENCODING

#rm -f $OUT_PATH/ggzgen/*.gpx
#java $OPTS -cp target/gsak2gpx-1.0-SNAPSHOT.jar ch.bubendorf.xmlsplit.XmlSplit --input $OUT_PATH/$GGZ.gpx --output $OUT_PATH/ggzgen --count $CACHES_PER_GPX --encoding $ENCODING
#/Users/mbu/src/ggz-tools/gpx2ggz.py $OUT_PATH/ggzgen/*.gpx $OUT_PATH/ggzgen/$GGZ.ggz