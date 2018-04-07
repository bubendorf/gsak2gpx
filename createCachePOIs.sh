#!/bin/bash

# Erzeugt die GPI Dateien mit GeoCaches

OPTS="-Xmx2G -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh
export IMG_PATH=$BASE/images/cachepoi

CATEGORIES=Traditional,Mystery,Multi,OtherCaches
#CATEGORIES=OtherCaches
# gpsbabel kommt NICHT mit utf-8 zurecht! Also nehmen wir halt das Windows-Zeugs!
# Valid values are windows-1250 to windows-1257.
#ENCODING=windows-1252
GPX_ENCODING=utf-8
GPI_ENCODING=windows-1252

java $OPTS -jar $JAR --database $DB --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $GPX_PATH --encoding $GPX_ENCODING --tasks $TASKS

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
  /bin/echo `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` Convert $1.gpx to $1.gpi
  START_TIME=`$DATE +%s%N`
#  echo Convert $1.gpx to $1.gpi
  gpsbabel -i gpx -f $GPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$IMG_PATH/$1.bmp,unique=0,writecodec=$GPI_ENCODING -F $OUT_PATH/$2.gpi
  replaceByte $OUT_PATH/$2.gpi 16 $4
  replaceByte $OUT_PATH/$2.gpi 17 $4
  STOP_TIME=`$DATE +%s%N`
  /bin/echo -n `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}

function multigpi {
# $1 Name der GPI Datei
# $2 Name der Kategorie
# $3 Name BMP Datei
# $4.. Namen der GPX Dateien
  /bin/echo `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` Converting to $1.gpi
  START_TIME=`$DATE +%s%N`
  OUT="-F $OUT_PATH/$1.gpi"
  EXEC="gpsbabel -D 0"
  for ((i=4;i<=$#;i+2))
  do
    EXEC="$EXEC -i gpx -f $GPX_PATH/${!i}.gpx"
  done
  EXEC="$EXEC -o garmin_gpi,category=$2,bitmap=$IMG_PATH/$3.bmp,unique=0,writecodec=$GPI_ENCODING -F $OUT_PATH/$1.gpi"
#  echo $EXEC
  $EXEC
  STOP_TIME=`$DATE +%s%N`
  /bin/echo -n `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}

togpi Traditional 20-Traditional "Traditional Cache" 20 &
togpi Mystery 22-Mystery "Mystery Cache" 22 &
togpi Multi 21-Multi "Multi Cache" 21 &
togpi OtherCaches 29-OtherCaches "Other Caches" 29 &

#togpi VirtualCache 23-VirtualCache VirtualCache 23 &
#togpi Letterbox 24-Letterbox Letterbox 24 &
#togpi Earthcache 25-Earthcache Earthcache 25 &
#togpi Wherigo 26-Wherigo Wherigo 26 &
#togpi Webcam 27-Webcam Webcam 27 &
#multigpi 29-OtherCaches OtherCaches OtherCaches VirtualCache Letterbox Earthcache Wherigo Webcam &

wait
