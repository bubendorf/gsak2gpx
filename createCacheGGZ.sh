#!/bin/sh
OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH="/Users/mbu/src/gsak2gpx/categories/ggz /Users/mbu/src/gsak2gpx/categories/include"
OUT_PATH=/Users/mbu/src/gsak2gpx/output
TASKS=1
#CATEGORIES=ActiveCaches
#CATEGORIES=UserFlagCaches
CATEGORIES=MainCaches
GGZ=$CATEGORIES
ENCODING=utf-8
CACHES_PER_GPX=300
MAX_SIZE=2980000

#java $OPTS -cp target/gsak2gpx-1.0.jar ch.bubendorf.gsak2gpx.Gsak2Gpx --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $OUT_PATH/ggzgen --tasks $TASKS --encoding $ENCODING
#java $OPTS -cp target/gsak2gpx-1.0.jar ch.bubendorf.ggzgen.GGZGen --input $OUT_PATH/ggzgen/$GGZ.gpx  --output $OUT_PATH/$GGZ.ggz --encoding $ENCODING --count $CACHES_PER_GPX --size $MAX_SIZE
java $OPTS -cp target/gsak2gpx-1.0.jar ch.bubendorf.gsak2gpx.Gsak2Gpx --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath - --tasks $TASKS --encoding $ENCODING | java $OPTS -cp target/gsak2gpx-1.0.jar ch.bubendorf.ggzgen.GGZGen --input - --output $OUT_PATH/$GGZ.ggz --encoding $ENCODING --count $CACHES_PER_GPX --size $MAX_SIZE

#rm -f $OUT_PATH/ggzgen/*.gpx
#java $OPTS -cp target/gsak2gpx-1.0.jar ch.bubendorf.xmlsplit.XmlSplit --input $OUT_PATH/$GGZ.gpx --output $OUT_PATH/ggzgen --count $CACHES_PER_GPX --size $MAX_SIZE --encoding $ENCODING
#/Users/mbu/src/ggz-tools/gpx2ggz.py $OUT_PATH/ggzgen/*.gpx $OUT_PATH/ggzgen/$GGZ.ggz
#mv $OUT_PATH/ggzgen/$GGZ.ggz $OUT_PATH/$GGZ.ggz
# rm $OUT_PATH/$GGZ.gpx

