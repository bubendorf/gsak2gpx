#!/bin/bash

# Erzeugt die RUPI Dateien für Sygic
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
. ./env.sh
cd $BASE
export PATH=/usr/local/bin:$PATH
export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"

export ENCODING=utf-8
export CAT_PATH="categories/rupi categories/include"

function createCSV() {
# $1 Namen der Kategorien
# $2 Land, muss dem GSAK Country entsprechen
# $3 0=Enabled, 1=Disabled, Leer=Egal
# $4 0=Ohne Corrected Coordinates, 1=Mit Corrected Coordinates, Leer=Egal
# $5 Suffix der erzeugten Datei
# $6 Extension der erzeugten Datei
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories $1 \
        --outputPath $CSV_PATH --outputFormat plainText --suffix $5 --extension $6 \
        --param country="$2" disabled=$3 corrected=$4 --encoding $ENCODING
}
export -f createCSV

function createCountry() {
# $1 Land (Switzerland, Germany, etc. Muss dem GSAK Country entsprechen)
# $2 Kuerzel des Landes (CH, DE, etc. Kann eigentlich beliebig sein)
  createCSV Parking "$1" "" "" $2_ .csv
  createCSV Event,Virtual,Physical "$1" 0 "" $2_ .csv
  createCSV Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox "$1" 0  0 $2_ .csv
  createCSV Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox "$1" 0  1 $2_ _Corr.csv
  createCSV Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox "$1" 1 "" $2_ _Disa.csv
}
export -f createCountry

function createFoundCSV() {
# $1 Land (Switzerland, Germany, etc. Muss dem GSAK Country entsprechen)
# $2 Kuerzel des Landes (CH, DE, etc. Kann eigentlich beliebig sein)
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $FOUND_DB` --categoryPath $CAT_PATH --categories Active \
        --outputPath $CSV_PATH --outputFormat plainText --suffix $2_ --extension _Found.csv \
        --param country="$1" found=1 --encoding $ENCODING
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $FOUND_DB` --categoryPath $CAT_PATH --categories Archived \
        --outputPath $CSV_PATH --outputFormat plainText --suffix $2_ --extension _Found.csv \
        --param country="$1" found=1 --encoding $ENCODING
}

function copyIcon() {
# $1 Name der Kategorie bzw. des Teilnames der Dateien
# $2 Kuerzel des Landes (CH, DE, etc.)
#echo "copyIcon mit $1 und $2"
#echo "ln $ICON_PATH/$1.bmp $RUPI_PATH/$2_$1.bmp"
  if [ -f $RUPI_PATH/$2_$1.rupi ]
  then
#echo "copyIcon mit $1 und $2"
#echo "ln $ICON_PATH/$1.bmp $RUPI_PATH/$2_$1.bmp"
    ln $ICON_PATH/$1.bmp $RUPI_PATH/$2_$1.bmp
  fi
}
export -f copyIcon

rm -f $CSV_PATH/*.csv
rm -f $RUPI_PATH/*.csv $RUPI_PATH/*.png $RUPI_PATH/*.bmp $RUPI_PATH/*.rupi

#createCSV Multi Germany 0 0 DE_ .csv
#$JAVA -jar $RUPI_JAR --outputPath $RUPI_PATH $CSV_PATH/TestTraditional.csv
#exit 0

# Export von GSAK nach CSV
echo "Export von GSAK nach CSV"
createFoundCSV Switzerland CH &
sleep 0.1
createFoundCSV Germany DE &
sleep 0.1
createFoundCSV France FR &
sleep 0.1
wait
#exit 0

parallel --delay 0.2 -j $TASKS -u createCountry ::: Switzerland Germany France Netherlands Liechtenstein Austria Italy Belarus Czechia Latvia Poland Finland Norway Sweden Estonia Ukraine Lithuania Russia Slovakia "Aland Islands" :::+ CH DE FR NL LI AT IT BY CZ LV PL FI NO SE EE UA LT RU SK AX
#exit 0

# Kleine (<15 Bytes) Dateien loeschen. Die enthalten keine Waypoints
find $CSV_PATH -name "*.csv" -size -15c -delete

# Die machen aus irgend einem Grunde Probleme!
rm -f $CSV_PATH/RU_Parking.csv
rm -f $CSV_PATH/RU_Unknown_Corr.csv
rm -f $CSV_PATH/IT_Wherigo_Corr.csv

# Convert CSV to RUPI
echo "Convert CSV to RUPI"
$JAVA -jar $RUPI_JAR --encoding $ENCODING --outputPath $RUPI_PATH $CSV_PATH/*.csv

echo "Verlinken der Icons"
parallel -j $TASKS -u copyIcon ::: \
         Active_Found Archived_Found Parking Traditional Traditional_Corr Traditional_Disa Multi \
         Multi_Corr Multi_Disa Unknown Unknown_Corr Unknown_Disa Wherigo Wherigo_Corr Wherigo_Disa \
         VirtualCache VirtualCache_Corr VirtualCache_Disa Earth Earth_Corr Earth_Disa Letterbox \
         Letterbox_Corr Letterbox_Disa Event Virtual Physical ::: \
         CH DE FR NL LI AT IT BY CZ LV PL FI NO SE EE UA LT RU SK AX

# Link copies to the various import folders
rm -f $SYGIC_PATH/*.csv $SYGIC_PATH/*.png $SYGIC_PATH/*.bmp $SYGIC_PATH/*.rupi
ln  $RUPI_PATH/* $SYGIC_PATH

rm -f $SYGIC_R8D8_PATH/*.csv $SYGIC_R8D8_PATH/*.png $SYGIC_R8D8_PATH/*.bmp $SYGIC_R8D8_PATH/*.rupi
ln $RUPI_PATH/* $SYGIC_R8D8_PATH

rm -f $SYGIC_R7D7_PATH/*.csv $SYGIC_R7D7_PATH/*.png $SYGIC_R7D7_PATH/*.bmp $SYGIC_R7D7_PATH/*.rupi
ln $RUPI_PATH/* $SYGIC_R7D7_PATH

rm -f $SYGIC_R4D4_PATH/*.csv $SYGIC_R4D4_PATH/*.png $SYGIC_R4D4_PATH/*.bmp $SYGIC_R4D4_PATH/*.rupi
ln $RUPI_PATH/* $SYGIC_R4D4_PATH

# Dem Syncthing ein "Scan" und "Override" schicken damit es Aenderungen von Clients ueberschreibt
echo "Start Trigger Syncthing"
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/scan?folder=default' &
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/override?folder=default' &
# SygicImportR8D8
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/scan?folder=yguh9-xjrqe' &
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/override?folder=yguh9-xjrqe' &
# SygicImportR7D7
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/scan?folder=tyhfd-qkcbz' &
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/override?folder=tyhfd-qkcbz' &
# SygicImportR4D4
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/scan?folder=m49bv-hare6' &
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/override?folder=m49bv-hare6' &

wait
echo "Ende Trigger Syncthing"

#createCountry Switzerland CH
#convertToRupi Parking
#convertToRupi Traditional
#convertToRupi Traditional_Corr
#convertToRupi Traditional_Disa
