#!/bin/sh
OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH="/Users/mbu/src/gsak2gpx/categories/attributepoi /Users/mbu/src/gsak2gpx/categories/include"
GPX_PATH=/Users/mbu/src/gsak2gpx/output/gpigen
OUT_PATH=/Users/mbu/src/gsak2gpx/output
TASKS=4
CATEGORIES=Favorites,Parking,Virtual,Reference,Trailhead,Simple,Physical,Original,Final,Disabled,Corrected,Terrain5
# gpsbabel kommt NICHT mit utf-8 zurecht!
ENCODING=windows-1252

java $OPTS -jar target/gsak2gpx-1.0-SNAPSHOT.jar --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $GPX_PATH --encoding $ENCODING --tasks $TASKS

function togpi {
# $1 Name der GPX und der BMP Dateien
# $2 Name der GPI Datei
# $3 Name der Kategorie
# $4 Time Offset
  echo Convert $1.gpx to $1.gpi
  gpsbabel -i gpx -f $GPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$GPX_PATH/$1.bmp,unique=0,writecodec=$ENCODING,notes,descr -F $OUT_PATH/$2.gpi
  #DATE=`dateadd now +1h +$4m -f "%m/%d/%Y %H:%M:$4"`
  #SetFile -d "$DATE" -m "$DATE" $OUT_PATH/$2.gpi
}

togpi Favorites 50-Attr-Favorites A-Favoriten 00 &
sleep 1
togpi Simple 51-Attr-Simple A-Simple 02 &
sleep 1
togpi Virtual 11-Virtual Virt-Stage 04 &
sleep 1
togpi Parking 52-Attr-Parking A-Parking 06 &
sleep 1
togpi Corrected 53-Attr-Corrected A-Corrected 08 &
sleep 1
togpi Original 34-Original Original 10 &
sleep 1
togpi Reference 33-Reference Ref-Point 12 &
sleep 1
togpi Trailhead 32-Trailhead Trailhead 14 &
sleep 1
togpi Physical 10-Physical Phys-Stage 16 &
sleep 1
togpi Terrain5 54-Attr-Terrain5 A-Terrain5 18 &
sleep 1
togpi Disabled 55-Attr-Disabled A-Disabled 20 &
sleep 1
togpi Final 31-Final Final 22 &

wait

