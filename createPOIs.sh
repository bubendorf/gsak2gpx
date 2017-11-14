#!/bin/sh
#OPTS="-Xmx2G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH="/Users/mbu/src/gsak2gpx/categories/attributepoi /Users/mbu/src/gsak2gpx/categories/include"
GPX_PATH=/Users/mbu/src/gsak2gpx/output/gpigen
OUT_PATH=/Users/mbu/src/gsak2gpx/output
TASKS=4
CATEGORIES=Favorites,Parking,Virtual,HasParking,Reference,Trailhead,Simple,Physical,Original,Final,Disabled,Corrected,Terrain5
# gpsbabel kommt NICHT mit utf-8 zurecht! Also nehmen wir halt das Windows-Zeugs!
ENCODING=windows-1252

java $OPTS -jar target/gsak2gpx-1.0.jar --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $GPX_PATH --encoding $ENCODING --tasks $TASKS

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
# $4 Time Offset, used to create unique GPI identifiers
  /bin/echo `gdate "+%Y-%m-%d %H:%M:%S:%3N"` Convert $1.gpx to $1.gpi
  START_TIME=`gdate +%s%N`
  gpsbabel -i gpx -f $GPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$GPX_PATH/$1.bmp,unique=0,writecodec=$ENCODING,notes,descr -F $OUT_PATH/$2.gpi
  replaceByte $OUT_PATH/$2.gpi 16 $4
  replaceByte $OUT_PATH/$2.gpi 17 $4
  STOP_TIME=`gdate +%s%N`
  /bin/echo -n `gdate "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}

togpi HasParking 52-Attr-HasParking A-HasParking 52 &
togpi Parking 35-Parking Parking 35 &
togpi Favorites 50-Attr-Favorites A-Favoriten 50 &
togpi Simple 51-Attr-Simple A-Simple 51 &
togpi Virtual 11-Virtual Virt-Stage 11 &
togpi Corrected 53-Attr-Corrected A-Corrected 53 &
togpi Original 34-Original Original 34 &
togpi Reference 33-Reference Ref-Point 33 &
togpi Trailhead 32-Trailhead Trailhead 32 &
togpi Physical 10-Physical Phys-Stage 10 &
togpi Terrain5 54-Attr-Terrain5 A-Terrain5 54 &
togpi Disabled 55-Attr-Disabled A-Disabled 55 &
togpi Final 31-Final Final 31 &

wait

