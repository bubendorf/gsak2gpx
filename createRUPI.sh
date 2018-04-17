#!/bin/bash

# Erzeugt die RUPI Dateien

export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh

export ENCODING=utf-8
export CAT_PATH="$BASE/categories/rupi $BASE/categories/include"

function createCSV() {
# $1 Namen der Kategorien
# $2 Land
# $3 0=Enabled, 1=Disabled, Leer=Egal
# $4 0=Ohne Corrected Coordinates, 1=Mit Corrected Coordinates, Leer=Egal
# $5 Suffix der erzeugten Datei
# $6 Extension der erzeugten Datei
  java $OPTS -jar $JAR --database $DB --categoryPath $CAT_PATH --categories $1 --outputPath $CSV_PATH --outputFormat plainText --suffix $5 --extension $6 --param country=$2 disabled=$3 corrected=$4 --encoding $ENCODING
#  FILENAME=$CSV_PATH/$5$1$6
#  echo $FILENAME
#  actualsize=$(stat -c%s $FILENAME)
#  minimumsize=15
#  if [ $actualsize -lt $minimumsize ]
#  then
#    echo "File $FILENAME is too small ==> Deleting"
#    rm $FILENAME
#  fi
}
export -f createCSV

#createCSV Parking Switzerland "" "" CH_ _Parking.csv
#createCSV Traditional France  $1 0 1 FR_ _Corr.csv
#exit 0

function createCountry() {
# $1 Land (Switzerland, Germany, etc.)
# $2 Kürzel des Landes (CH, DE, etc.)

  createCSV Parking $1 "" "" $2_ .csv
  createCSV Traditional,Multi,Unknown,Wherigo,Virtual,Earth,Letterbox $1 0 "" $2_ .csv
  createCSV Traditional,Multi,Unknown,Wherigo,Virtual,Earth,Letterbox $1 0  1 $2_ _Corr.csv
  createCSV Traditional,Multi,Unknown,Wherigo,Virtual,Earth,Letterbox $1 1 "" $2_ _Disa.csv
}
export -f createCountry

function convertToRupi() {
# $1 Name der Kategorie bzw. des Teilnames der Dateien
# $2 Kürzel des Landes (CH, DE, etc.)
  if [ -f $CSV_PATH/$2_$1.csv ]
  then 
    java -jar $RUPI_JAR  --encoding $ENCODING -n $2_$1 -o $RAWRUPI_PATH $CSV_PATH/$2_$1.csv
    cp $ICON_PATH/$1.bmp $RAWRUPI_PATH/$2_$1.bmp
#  else
#    echo "$CSV_PATH/$2_$1.csv does not exist!"
  fi
}
export -f convertToRupi

rm -rf $RAWRUPI_PATH/*

# Export von GSAK nach CSV
parallel --delay 0.1s -j $TASKS -u createCountry ::: Switzerland Germany France Netherlands Liechtenstein Austria Italy :::+ CH DE FR NL LI AT IT

# Kleine Dateien löschen. Die enthalten keine Waypoints
find $CSV_PATH -name "*.csv" -size -15c -delete

# Convert CSV to RUPI
java -jar $RUPI_JAR --encoding $ENCODING --outputPath $RAWRUPI_PATH $CSV_PATH/*.csv
# parallel -j $TASKS -u convertToRupi ::: Parking Traditional Traditional_Corr Traditional_Disa Multi Multi_Corr Multi_Disa Unknown Unknown_Corr Unknown_Disa Wherigo Wherigo_Corr Wherigo Virtual Virtual_Corr Virtual_Disa Earth Earth_Corr Earth_Disa Letterbox Letterbox_Corr Letterbox_Disa ::: CH DE FR NL LI AT IT

#createCountry Switzerland CH
#convertToRupi Parking
#convertToRupi Traditional
#convertToRupi Traditional_Corr
#convertToRupi Traditional_Disa
