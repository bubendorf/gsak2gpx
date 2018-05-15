#!/bin/bash

# Creates the GGZ files

export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh

export ENCODING=utf-8
# Maximum number of geocaches in a single GPX file within the GGZ file
export CACHES_PER_GPX=300
# Maximum uncompressed size of a single GPX file within the GGZ file
export MAX_SIZE=2985000

function doit() {
# $1 Name der Kategorie
# $2 Name der GGZ Datei
# $3 BoundingBox Min-Latitude
# $4 BoundingBox Max-Latitude
# $5 BoundingBox Min-Longitude
# $6 BoundingBox Max-Longitude
  if [ -z "$2" ]
  then
    GGZNAME=$1
  else
    GGZNAME=$2
  fi
  java $OPTS -jar $JAR --database $DB --categoryPath $CAT_PATH --categories $1 --param minlat=$3 maxlat=$4 minlon=$5 maxlon=$6 --outputPath - --encoding $ENCODING | java $OPTS -cp $JAR ch.bubendorf.ggzgen.GGZGenKt --input - --output $OUT_PATH/$GGZNAME.ggz --encoding $ENCODING --count $CACHES_PER_GPX --size $MAX_SIZE
}
export -f doit

# Delete all GGZ files from the output directory
rm -f $OUT_PATH/*.ggz

# Get the number of geocaches to export. Depending on that number one, two or four GGZ files are created
COUNT=`sqlite3 $DB 'select count(*) from caches where userflag = 1'`
echo "Anzahl Geocaches: $COUNT"
if [ $COUNT -ge 5000 ]
then
  MIDDLE_LON=`sqlite3 $DB 'select round(longitude, 6) from Caches where userflag = 1 order by longitude limit 1 offset round((select count(*) from Caches where userflag = 1)/2);'`
  echo "Medium Longitude=$MIDDLE_LON"
  if [ $COUNT -ge 10000 ]
  then
    MIDDLE_LAT=`sqlite3 $DB 'select round(latitude, 6) from Caches where userflag = 1 order by latitude limit 1 offset round((select count(*) from Caches where userflag = 1)/2);'`
    echo "Medium Latitude=$MIDDLE_LAT"
   (echo UserFlagBBox UserFlagNordOst $MIDDLE_LAT 90 $MIDDLE_LON 180; echo UserFlagBBox UserFlagNordWest $MIDDLE_LAT 90 -180 $MIDDLE_LON; echo UserFlagBBox UserFlagSuedOst -90 $MIDDLE_LAT $MIDDLE_LON 180; echo UserFlagBBox UserFlagSuedWest -90 $MIDDLE_LAT -180 $MIDDLE_LON;) | parallel --delay 0.5 --colsep " " -j $TASKS --ungroup doit
  else
    (echo UserFlagBBox UserFlagOst -90 90 $MIDDLE_LON 180; echo UserFlagBBox UserFlagWest -90 90 -180 $MIDDLE_LON;) | parallel --delay 0.5 --colsep " " -j $TASKS --ungroup doit 
  fi
else
  doit UserFlagCaches
fi

# parallel --delay 1 -j $TASKS -u doit ::: E8_Nord E7_Nord E5_6 E9_10 E7_8_Sued
# parallel --delay 1 -j $TASKS -u doit ::: UserFlagOst UserFlagWest
# doit UserFlagCaches
