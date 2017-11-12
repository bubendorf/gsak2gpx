#!/bin/sh
OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH="/Users/mbu/src/gsak2gpx/categories/cachepoi /Users/mbu/src/gsak2gpx/categories/include"
GPX_PATH=/Users/mbu/src/gsak2gpx/output/cachepoi
OUT_PATH=/Users/mbu/src/gsak2gpx/output
TASKS=4
CATEGORIES=Traditional,Unknown,Multi,VirtualCache,Earthcache,Wherigo,Webcam,Letterbox
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
}

togpi Traditional 20-Traditional Traditional 20 &
togpi Unknown 22-Unknown Unknown 22 &
togpi Multi 21-Multi Multi 21 &
togpi VirtualCache 23-VirtualCache VirtualCache 23 &
togpi Letterbox 24-Letterbox Letterbox 24 &
togpi Earthcache 25-Earthcache Earthcache 25 &
togpi Wherigo 26-Wherigo Wherigo 26 &
togpi Webcam 27-Webcam Webcam 27 &

wait
