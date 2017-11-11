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

# param 1: file
# param 2: offset
# param 3: value
function replaceByte() {
    printf "$(printf '\\x%02X' $3)" | dd of="$1" bs=1 seek=$2 count=1 conv=notrunc &> /dev/null
}

function togpi {
# $1 Name der GPX und der BMP Dateien
# $2 Name der GPI Datei
# $3 Name der Kategorie
# $4 Time Offset
  echo Convert $1.gpx to $1.gpi
  gpsbabel -i gpx -f $GPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$GPX_PATH/$1.bmp,unique=0,writecodec=$ENCODING,notes,descr -F $OUT_PATH/$2.gpi
  replaceByte $OUT_PATH/$2.gpi 16 $4
  replaceByte $OUT_PATH/$2.gpi 17 $4

  #DATE=`dateadd now +1h +$4m -f "%m/%d/%Y %H:%M:$4"`
  #SetFile -d "$DATE" -m "$DATE" $OUT_PATH/$2.gpi
}

togpi Favorites 50-Attr-Favorites A-Favoriten 0 &
togpi Simple 51-Attr-Simple A-Simple 1 &
togpi Virtual 11-Virtual Virt-Stage 2 &
togpi Parking 52-Attr-Parking A-Parking 3 &
togpi Corrected 53-Attr-Corrected A-Corrected 4 &
togpi Original 34-Original Original 5 &
togpi Reference 33-Reference Ref-Point 6 &
togpi Trailhead 32-Trailhead Trailhead 7 &
togpi Physical 10-Physical Phys-Stage 8 &
togpi Terrain5 54-Attr-Terrain5 A-Terrain5 9 &
togpi Disabled 55-Attr-Disabled A-Disabled 10 &
togpi Final 31-Final Final 11 &

wait

