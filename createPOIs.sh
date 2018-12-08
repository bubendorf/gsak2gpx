#!/bin/bash

# Erzeugt die GPI Dateien mit den Attributen und sonstigen Zusatzinfos

#OPTS="-Xmx2G"
. ./env.sh
export IMG_PATH=images/gpigen

CATEGORIES=Favorites,Parking,Virtual,HasParking,Reference,Trailhead,Simple,Physical,Original,Final,Disabled,Corrected,Terrain5,Tour1,Tour2,Tour3
#CATEGORIES=HasParking
# gpsbabel kommt NICHT mit utf-8 zurecht! Also nehmen wir halt das Windows-Zeugs!
# Valid values are windows-1250 to windows-1257.
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
  rm -f $GPI_PATH/$2.gpi
  filesize=$( wc -c "$POIGPX_PATH/$1.gpx" | awk '{print $1}' )
  if [ $filesize -ge 550 ]
  then
	  /bin/echo `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` Convert $1.gpx to $1.gpi
	  START_TIME=`$DATE +%s%N`
	  $GPSBABEL -i gpx -f $POIGPX_PATH/$1.gpx -o garmin_gpi,category="$3",bitmap=$IMG_PATH/$1.bmp,unique=0,writecodec=$GPI_ENCODING -F $GPI_PATH/$2.gpi
	  replaceByte $GPI_PATH/$2.gpi 16 $4
	  replaceByte $GPI_PATH/$2.gpi 17 $4
	  STOP_TIME=`$DATE +%s%N`
	  /bin/echo -n `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
	  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
  else
    echo "File $POIGPX_PATH/$1.gpx is empty. Skipping!"
  fi
}

function multigpi {
# $1 Name der GPI Datei
# $2.. Name der GPX und der BMP Dateien
# $3.. Name der Kategorie
  /bin/echo `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` Converting to $1.gpi
  START_TIME=`$DATE +%s%N`
  OUT="-F $GPI_PATH/$1.gpi"
  EXEC="$GPSBABEL -D 0"
  for ((i=2;i<=$#;i+=2))
  do
    let j=i+1
    EXEC="$EXEC -i gpx -f $POIGPX_PATH/${!i}.gpx -o garmin_gpi,category=\"${!j}\",bitmap=$IMG_PATH/${!i}.bmp,unique=0,writecodec=$GPI_ENCODING"
  done
  EXEC="$EXEC -F $GPI_PATH/$1.gpi"
#  echo $EXEC
  $EXEC
  STOP_TIME=`$DATE +%s%N`
  /bin/echo -n `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}

# multigpi 99-Attributes.gpi Favorites A-Favoriten Simple A-Simple HasParking A-HasParking Corrected A-Corrected Terrain5 A-Terrain5 Disabled A-Disabled

java $OPTS -jar $JAR --database `$CYG2DOS $DB` --categoryPath $CAT_PATH --categories $CATEGORIES --outputPath $POIGPX_PATH --encoding $GPX_ENCODING --tasks $TASKS

togpi HasParking 52-Attr-HasParking A-HasParking 52 &
togpi Parking 35-Parking "Parking Place" 35 &
togpi Favorites 50-Attr-Favorites A-Favoriten 50 &
togpi Simple 51-Attr-Simple A-Simple 51 &
togpi Virtual 16-Virtual "Virtual Stage" 16 &
togpi Corrected 53-Attr-Corrected A-Corrected 53 &
togpi Original 34-Original "Original Coordinats" 34 &
togpi Reference 33-Reference "Reference Point" 33 &
togpi Trailhead 32-Trailhead Trailhead 32 &
togpi Physical 17-Physical "Physical Stage" 17 &
togpi Terrain5 54-Attr-Terrain5 A-Terrain5 54 &
togpi Disabled 55-Attr-Disabled A-Disabled 55 &
togpi Final 31-Final Final 31 &
togpi Tour1 10-Tour1 "Tour 1" 10 &
togpi Tour2 11-Tour2 "Tour 2" 11 &
togpi Tour3 12-Tour3 "Tour 3" 12 &
wait
