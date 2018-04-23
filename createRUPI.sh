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
}
export -f createCSV

function createCountry() {
# $1 Land (Switzerland, Germany, etc.)
# $2 Kue�rzel des Landes (CH, DE, etc.)
  createCSV Parking $1 "" "" $2_ .csv
  createCSV Traditional,Multi,Unknown,Wherigo,Virtual,Earth,Letterbox $1 0 "" $2_ .csv
  createCSV Traditional,Multi,Unknown,Wherigo,Virtual,Earth,Letterbox $1 0  1 $2_ _Corr.csv
  createCSV Traditional,Multi,Unknown,Wherigo,Virtual,Earth,Letterbox $1 1 "" $2_ _Disa.csv
}
export -f createCountry

function copyIcon() {
# $1 Name der Kategorie bzw. des Teilnames der Dateien
# $2 Kue�rzel des Landes (CH, DE, etc.)
  if [ -f $RUPI_PATH/$2_$1.rupi ]
  then
    ln $ICON_PATH/$1.bmp $RUPI_PATH/$2_$1.bmp
  fi
}
export -f copyIcon

rm -f $CSV_PATH/*.csv
rm -f $RUPI_PATH/*.csv $RUPI_PATH/*.png $RUPI_PATH/*.bmp $RUPI_PATH/*.rupi

# Export von GSAK nach CSV
parallel --delay 0.1s -j $TASKS -u createCountry ::: Switzerland Germany France Netherlands Liechtenstein Austria Italy :::+ CH DE FR NL LI AT IT

# Kleine Dateien löschen. Die enthalten keine Waypoints
find $CSV_PATH -name "*.csv" -size -15c -delete

# Convert CSV to RUPI
java -jar $RUPI_JAR --encoding $ENCODING --outputPath $RUPI_PATH $CSV_PATH/*.csv
parallel -j $TASKS -u copyIcon ::: Parking Traditional Traditional_Corr Traditional_Disa Multi Multi_Corr Multi_Disa Unknown Unknown_Corr Unknown_Disa Wherigo Wherigo_Corr Wherigo_Disa Virtual Virtual_Corr Virtual_Disa Earth Earth_Corr Earth_Disa Letterbox Letterbox_Corr Letterbox_Disa ::: CH DE FR NL LI AT IT

rm -f $SYGIC_R7D7_PATH/*.csv $SYGIC_R7D7_PATH/*.png $SYGIC_R7D7_PATH/*.bmp $SYGIC_R7D7_PATH/*.rupi
ln $RUPI_PATH/* $SYGIC_R7D7_PATH
rm -f $SYGIC_R3D3_PATH/*.csv $SYGIC_R3D3_PATH/*.png $SYGIC_R3D3_PATH/*.bmp $SYGIC_R3D3_PATH/*.rupi
ln $RUPI_PATH/* $SYGIC_R3D3_PATH

# Dem Syncthing ein "Scan" und "Override" schicken damit es e Aenderungen von Clients ueberschreibt
echo Trigger Syncthing
curl -X POST -H 'X-API-Key: 2TGSSVxpbaogJ5rQ7hAajHk6ebfUQGRf' 'http://127.0.0.1:8384/rest/db/scan?folder=t5mtj-tmdkt'
curl -X POST -H 'X-API-Key: 2TGSSVxpbaogJ5rQ7hAajHk6ebfUQGRf' 'http://127.0.0.1:8384/rest/db/override?folder=t5mtj-tmdkt'
curl -X POST -H 'X-API-Key: 2TGSSVxpbaogJ5rQ7hAajHk6ebfUQGRf' 'http://127.0.0.1:8384/rest/db/scan?folder=tyhfd-qkcbz'
curl -X POST -H 'X-API-Key: 2TGSSVxpbaogJ5rQ7hAajHk6ebfUQGRf' 'http://127.0.0.1:8384/rest/db/override?folder=tyhfd-qkcbz'

#createCountry Switzerland CH
#convertToRupi Parking
#convertToRupi Traditional
#convertToRupi Traditional_Corr
#convertToRupi Traditional_Disa
