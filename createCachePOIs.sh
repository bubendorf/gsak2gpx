#!/bin/sh
#OPTS="-Xmx6G"
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
CAT_PATH="/Users/mbu/src/gsak2gpx/categories/cachepoi /Users/mbu/src/gsak2gpx/categories/include"
GPX_PATH=/Users/mbu/src/gsak2gpx/output/cachepoi
OUT_PATH=/Users/mbu/src/gsak2gpx/output
IMG_PATH=/Users/mbu/src/gsak2gpx/images/cachepoi
TASKS=4
CATEGORIES=Traditional,Unknown,Multi,VirtualCache,Earthcache,Wherigo,Webcam,Letterbox
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
#  echo Convert $1.gpx to $1.gpi
  gpsbabel -i gpx -f $GPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$IMG_PATH/$1.bmp,unique=0,writecodec=$ENCODING -F $OUT_PATH/$2.gpi
  replaceByte $OUT_PATH/$2.gpi 16 $4
  replaceByte $OUT_PATH/$2.gpi 17 $4
  STOP_TIME=`gdate +%s%N`
  /bin/echo -n `gdate "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}

function multigpi {
# $1 Name der GPI Datei
# $2.. Name der GPX und der BMP Dateien
# $3.. Name der Kategorie
  /bin/echo `gdate "+%Y-%m-%d %H:%M:%S:%3N"` Converting to $1.gpi
  START_TIME=`gdate +%s%N`
  OUT="-F $OUT_PATH/$1.gpi"
  EXEC="gpsbabel -D 0"
  for ((i=2;i<=$#;i+=2))
  do
    let j=i+1
    EXEC="$EXEC -i gpx -f $GPX_PATH/${!i}.gpx -o garmin_gpi,category=\"${!j}\",bitmap=$IMG_PATH/${!i}.bmp,unique=0,writecodec=$ENCODING"
  done
  EXEC="$EXEC -F $OUT_PATH/$1.gpi"
#  echo $EXEC
  $EXEC
  STOP_TIME=`gdate +%s%N`
  /bin/echo -n `gdate "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}

togpi Traditional 20-Traditional Traditional 20 &
togpi Unknown 22-Unknown Unknown 22 &
togpi Multi 21-Multi Multi 21 &
sleep 2
togpi VirtualCache 23-VirtualCache VirtualCache 23 &
togpi Letterbox 24-Letterbox Letterbox 24 &
togpi Earthcache 25-Earthcache Earthcache 25 &
togpi Wherigo 26-Wherigo Wherigo 26 &
togpi Webcam 27-Webcam Webcam 27 &
#multigpi 29-CachePOI VirtualCache VirtualCache Letterbox Letterbox Earthcache Earthcache Wherigo Wherigo Webcam Webcam &

wait
