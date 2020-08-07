#!/bin/bash

# Erzeugt die GPI Dateien mit den Attributen und sonstigen Zusatzinfos

#OPTS="-Xmx2G"
. ./env.sh
export IMG_PATH=images/gpigen

CATEGORIES=Favorites,Parking,Virtual,HasParking,Reference,Trailhead,\
Simple,Physical,Original,Final,Disabled,Corrected,Terrain5,Gemeinde0,\
Tour1,Tour2,Tour3,Tour4

#CATEGORIES=HasParking
# gpsbabel kommt NICHT mit utf-8 zurecht! Also nehmen wir halt das Windows-Zeugs!
# Valid values are windows-1250 to windows-1257.
export GPX_ENCODING=utf-8
export GPI_ENCODING=windows-1252

# param 1: file
# param 2: offset
# param 3: value
function replaceByte() {
    printf "$(printf '\\x%02X' $3)" | dd of="$1" bs=1 seek=$2 count=1 conv=notrunc &> /dev/null
}
export -f replaceByte

function togpi {
# $1 Name der GPX und der BMP Dateien
# $2 Name der GPI Datei
# $3 Name der Kategorie
# $4 Time Offset, used to create unique GPI identifiers
  . ./env.sh
  rm -f $GPI_PATH/$2.gpi
  filesize=$( wc -c "$POIGPX_PATH/$1.gpx" | awk '{print $1}' )
  if [ $filesize -ge 760 ]
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
export -f togpi

function multigpi {
# $1 Name der GPI Datei, ohne die Endung
# $2 Time Offset, used to create unique GPI identifiers
# $3 Prefix für die Dateinamen und damit die Kategorie
# $4.. Namen der GPX und der BMP Dateien
  . ./env.sh
  rm -f $GPI_PATH/$1.gpi
  TEMP_PATH=$OUT_PATH/gpigen/$1
#  echo "TEMP_PATH=$TEMP_PATH"
  mkdir -p $TEMP_PATH
  rm -f $TEMP_PATH/*
  /bin/echo `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` Converting to $1.gpi
  START_TIME=`$DATE +%s%N`

  for ((i=4;i<=$#;i+=1))
  do
    filesize=$( wc -c "$POIGPX_PATH/${!i}.gpx" | awk '{print $1}' )
    if [ $filesize -ge 760 ]
    then
      # GPX und BMP kopieren bzw. verlinken
	  ln "$POIGPX_PATH/${!i}.gpx" "$TEMP_PATH/$3${!i}.gpx" 
	  ln "$IMG_PATH/${!i}.bmp" "$TEMP_PATH/$3${!i}.bmp"
    else
      echo "File $POIGPX_PATH/${!i}.gpx is empty. Skipping!"
    fi
  done
  touch $GPI_PATH/$1.gpi
  $GPIGEN $(wslpath -a -w $TEMP_PATH) $(wslpath -a -w $GPI_PATH/$1.gpi)
  replaceByte $GPI_PATH/$1.gpi 16 $2
  replaceByte $GPI_PATH/$1.gpi 17 $2
  STOP_TIME=`$DATE +%s%N`
  /bin/echo -n `$DATE "+%Y-%m-%d %H:%M:%S:%3N"` "Finished $1.gpi after "
  /bin/echo "($STOP_TIME-$START_TIME)/1000000" | bc
}
export -f multigpi

# multigpi 99-Attributes.gpi Favorites A-Favoriten Simple A-Simple HasParking A-HasParking Corrected A-Corrected Terrain5 A-Terrain5 Disabled A-Disabled
#multigpi 50-Attributes1 50 A- Gemeinde0 Simple Terrain5
#exit 0

$JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` \
      --categoryPath $CAT_PATH --categories $CATEGORIES \
      --outputPath $POIGPX_PATH --encoding $GPX_ENCODING --tasks $TASKS

parallel --jobs 5 ::: \
 'multigpi 50-Attributes1 50 A- Gemeinde0 Simple Terrain5 ' \
 'multigpi 51-Attributes2 51 A- Corrected HasParking Favorites Disabled' \
 'multigpi 30-Waypoints   30 "" Parking Original Reference Trailhead Final' \
 'multigpi 10-Tour1-4     10 "" Tour1 Tour2 Tour3 Tour4' \
 'multigpi 18-VirtPhys    18 "" Virtual Physical' \

exit 0

parallel --jobs 5 ::: \
 'togpi Gemeinde0 49-Attr-Gemeinde0 A-Gemeinde0 49' \
 'togpi Corrected 53-Attr-Corrected A-Corrected 53 &' \
 'togpi HasParking 52-Attr-HasParking "A-HasParking" 52' \
 'togpi Virtual 16-Virtual "Virtual Stage" 16' \
 'togpi Parking 35-Parking "Parking Place" 35' \
 'togpi Simple 51-Attr-Simple "A-Simple" 51' \
 'togpi Original 34-Original "Original Coordinats" 34' \
 'togpi Reference 33-Reference "Reference Point" 33' \
 'togpi Trailhead 32-Trailhead Trailhead 32' \
 'togpi Physical 17-Physical "Physical Stage" 17' \
 'togpi Favorites 50-Attr-Favorites A-Favoriten 50' \
 'togpi Terrain5 54-Attr-Terrain5 A-Terrain5 54' \
 'togpi Disabled 55-Attr-Disabled A-Disabled 55' \
 'togpi Final 31-Final Final 31' \
 'multigpi 10-Tour1-4 10 Tour1 "Tour-1" Tour2 "Tour-2" Tour3 "Tour-3" Tour4 "Tour-4"'
exit 0 
 'togpi Tour1 10-Tour1 "Tour 1" 10' \
 'togpi Tour2 11-Tour2 "Tour 2" 11' \
 'togpi Tour3 12-Tour3 "Tour 3" 12' \
 'togpi Tour4 13-Tour4 "Tour 4" 13'
