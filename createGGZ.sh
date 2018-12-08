#!/bin/bash

# Creates the GGZ files

export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh

./updateSmartNames.sh

export ENCODING=utf-8
# Maximum number of geocaches in a single GPX file within the GGZ file
# export CACHES_PER_GPX=300
export CACHES_PER_GPX=100
# Maximum uncompressed size of a single GPX file within the GGZ file
# export MAX_SIZE=2985000
export MAX_SIZE=1536000

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
  # Teil 1: Aus den Caches der Datenbank eine GPX Datei erzeugen
  # Teil 2: Und direkt in den GPX_TO_GGZ Konverter rein schreiben
  java $OPTS -jar $JAR --database `$CYG2DOS $DB` --categoryPath $CAT_PATH --categories $1 --param minlat=$3 maxlat=$4 minlon=$5 maxlon=$6 --outputPath - --encoding $ENCODING | \
  tee $GGZGPX_PATH/$GGZNAME.gpx | \
  java $OPTS -cp $JAR ch.bubendorf.ggzgen.GGZGenKt --input - --output $GGZ_PATH/$GGZNAME.ggz --name $GGZNAME.gpx --encoding $ENCODING --count $CACHES_PER_GPX --size $MAX_SIZE
}
export -f doit

# Delete all GGZ files from the output directory
rm -f $GGZ_PATH/*.ggz

# Get the number of geocaches to export. Depending on that number one, two or four GGZ files are created
COUNT=`sqlite3 $DB 'select count(*) from caches where userflag = 1'`
echo "Anzahl Geocaches: $COUNT"
if [ $COUNT -ge 5000 ]
then
  MIDDLE_LON=`sqlite3 $DB 'select round(longitude, 6) from Caches where userflag = 1 order by longitude limit 1 offset round((select count(*) from Caches where userflag = 1)/2);'`
  echo "Medium Longitude=$MIDDLE_LON"
  if [ $COUNT -ge 10000 ]
  then
    # Create four GGZ files
    MIDDLE_LAT_WEST=`sqlite3 $DB "select round(latitude, 6) from Caches where userflag = 1 and longitude+0.0 <  $MIDDLE_LON order by latitude limit 1 offset round((select count(*) from Caches where userflag = 1 and longitude+0.0 <  $MIDDLE_LON)/2);"`
    MIDDLE_LAT_EAST=`sqlite3 $DB "select round(latitude, 6) from Caches where userflag = 1 and longitude+0.0 >= $MIDDLE_LON order by latitude limit 1 offset round((select count(*) from Caches where userflag = 1 and longitude+0.0 >= $MIDDLE_LON)/2);"`
    echo "Medium Latitude (West)=$MIDDLE_LAT_WEST"
    echo "Medium Latitude (East)=$MIDDLE_LAT_EAST"
   (echo UserFlagBBox NordOst $MIDDLE_LAT_EAST 90 $MIDDLE_LON 180; echo UserFlagBBox NordWest $MIDDLE_LAT_WEST 90 -180 $MIDDLE_LON; echo UserFlagBBox SuedOst -90 $MIDDLE_LAT_EAST $MIDDLE_LON 180; echo UserFlagBBox SuedWest -90 $MIDDLE_LAT_WEST -180 $MIDDLE_LON;) | parallel --delay 0.5 --colsep " " -j $TASKS --ungroup doit
  else
    # Create two GGZ files
    (echo UserFlagBBox Ost -90 90 $MIDDLE_LON 180; echo UserFlagBBox West -90 90 -180 $MIDDLE_LON;) | parallel --delay 0.5 --colsep " " -j $TASKS --ungroup doit
  fi
else
  # Create one single GGZ file
  doit UserFlagCaches caches
fi

# parallel --delay 1 -j $TASKS -u doit ::: E8_Nord E7_Nord E5_6 E9_10 E7_8_Sued
# parallel --delay 1 -j $TASKS -u doit ::: UserFlagOst UserFlagWest
# doit UserFlagCaches
