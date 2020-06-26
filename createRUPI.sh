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

function createCountry() {
# $1 Sygic Region/Gebiet
  mkdir -p $CSV_PATH/$1

# Found Active
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $FOUND_DB` --categoryPath $CAT_PATH --categories Active \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _Found.csv \
        --param sygic="$1" found=1 --encoding $ENCODING

#Found Archived
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $FOUND_DB` --categoryPath $CAT_PATH --categories Archived \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _Found.csv \
        --param sygic="$1" found=1 --encoding $ENCODING

# Parking in 0er Gemeinden
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Parking \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _G0.csv \
        --param sygic="$1" gemeinde0=0 --encoding $ENCODING

# Parking in bereits gefundenen Gemeinden
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Parking \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension .csv \
        --param sygic="$1" gemeinde0=1 --encoding $ENCODING

# Alle Event,Virtual,Physical
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Event,Virtual,Physical \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension .csv \
        --param sygic="$1" disabled=0 --encoding $ENCODING

# Active, Not corrected, 0er Gemeinden
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _G0.csv \
        --param sygic="$1" disabled=0 corrected=0 gemeinde0=0 --encoding $ENCODING

# Active, Corrected, 0er Gemeinden
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _Corr_G0.csv \
        --param sygic="$1" disabled=0 corrected=1 gemeinde0=0 --encoding $ENCODING

# Active, Not corrected, Gefundene Gemeinden
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension .csv \
        --param sygic="$1" disabled=0 corrected=0 gemeinde0=1 --encoding $ENCODING

# Active, Corrected, Gefundene Gemeinden
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _Corr.csv \
        --param sygic="$1" disabled=0 corrected=1 gemeinde0=1 --encoding $ENCODING

# Disabled
  $JAVA $OPTS -jar $JAR --database `$CYG2DOS $DB $DB2` --categoryPath $CAT_PATH --categories Traditional,Multi,Unknown,Wherigo,VirtualCache,Earth,Letterbox \
        --outputPath $CSV_PATH/$1 --outputFormat plainText --extension _Disa.csv \
        --param sygic="$1" disabled=1 --encoding $ENCODING

  # Kleine (<15 Bytes) Dateien loeschen. Die enthalten keine Waypoints
  find $CSV_PATH/$1 -name "*.csv" -size -15c -delete

  mkdir -p $RUPI_PATH/$1
  $JAVA -jar $RUPI_JAR --tasks 3 --encoding $ENCODING --outputPath $RUPI_PATH/$1 $CSV_PATH/$1/*.csv
}
export -f createCountry


function copyIcon() {
# $1 Name der Kategorie bzw. des Teilnames der Dateien
# $2 Sygic Region
  if [ -f $RUPI_PATH/$2/$1.rupi ]
  then
    ln $ICON_PATH/$1.bmp $RUPI_PATH/$2/$1.bmp
  fi
}
export -f copyIcon

rm -f $CSV_PATH/**/*.csv
rmdir $CSV_PATH/*
rm -f $RUPI_PATH/**/*.rupi
rmdir $RUPI_PATH/*

function printArgs() {
  echo $*
}
export -f printArgs

if true
then
parallel --delay 0.2 -j $TASKS -u createCountry ::: \
         che deu03 fra08 fra07 ita02 aut fra06 lie deu02 deu07 deu04
fi

# Dem Syncthing ein "Scan" und "Override" schicken damit es Aenderungen von Clients ueberschreibt
echo "Start Trigger Syncthing"
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/scan?folder=eviw2-zxkts'
curl -s -X POST -H "X-API-Key: $SYNCTHING_KEY" 'http://127.0.0.1:8384/rest/db/override?folder=eviw2-zxkts' &

exit 0

echo "Verlinken der Icons"
parallel -j $TASKS -u copyIcon ::: \
         Active_Found Archived_Found Parking Parking_G0 \
         Traditional Traditional_Corr Traditional_G0 Traditional_Corr_G0 Traditional_Disa \
         Multi Multi_Corr Multi_G0 Multi_Corr_G0 Multi_Disa \
         Unknown Unknown_Corr Unknown_G0 Unknown_Corr_G0 Unknown_Disa \
         Wherigo Wherigo_Corr Wherigo_G0 Wherigo_Corr_G0 Wherigo_Disa \
         VirtualCache VirtualCache_Corr VirtualCache_G0 VirtualCache_Corr_G0 VirtualCache_Disa \
         Earth Earth_Corr Earth_G0 Earth_Corr_G0 Earth_Disa \
         Letterbox Letterbox_Corr Letterbox_G0 Letterbox_Corr_G0 Letterbox_Disa \
         Event Virtual Physical ::: \
         che deu03 fra08 lie aut ita

