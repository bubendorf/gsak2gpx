#!/bin/bash

# Erzeugt die GPI Dateien mit GeoCaches

OPTS="-Xmx2G -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh
export IMG_PATH=images/cachepoi

CATEGORIES=AllActiveCaches
# gpsbabel kommt NICHT mit utf-8 zurecht! Also nehmen wir halt das Windows-Zeugs!
# Valid values are windows-1250 to windows-1257.
#ENCODING=windows-1252
GPX_ENCODING=utf-8
GPI_ENCODING=windows-1252

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
  rm -f $FENIX_PATH/$2.gpi
  filesize=$( wc -c "$POIGPX_PATH/$1.gpx" | awk '{print $1}' )
  if [ $filesize -ge 550 ]
  then
	  /bin/echo `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` Convert $1.gpx to $1.gpi
	  START_TIME=`$DATE +%s%N`
	#  echo Convert $1.gpx to $1.gpi
	  $GPSBABEL -i gpx -f $POIGPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$IMG_PATH/$1.bmp,unique=0,writecodec=$GPI_ENCODING -F $FENIX_PATH/$2.gpi
	  replaceByte $FENIX_PATH/$2.gpi 16 $4
	  replaceByte $FENIX_PATH/$2.gpi 17 $4
	  STOP_TIME=`$DATE +%s%N`
	  /bin/echo -n `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
	  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
  else
    echo "File $POIGPX_PATH/$1.gpx is empty. Skipping!"
  fi
}

java $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $POIGPX_PATH --encoding $GPX_ENCODING --tasks $TASKS
togpi AllActiveCaches AllActiveCaches "Caches" 57
