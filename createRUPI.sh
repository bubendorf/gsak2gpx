#!/bin/bash

# Erzeugt die RUPI Dateien

export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh

export ENCODING=iso8859-1
export CAT_PATH="$BASE/categories/rupi $BASE/categories/include"

function createRupi() {
# $1 Name der Kategorie(-n)
# $2 Land
# $3 0=Enabled, 1=Disabled, Leer=Egal
# $4 0=Ohne Corrected Coordinates, 1=Mit Corrected Coordinates, Leer=Egal
# $5 Suffix der erzeugten Datei
# $6 Extension der erzeugten Datei
  java $OPTS -jar $JAR --database $DB --categoryPath $CAT_PATH --categories $1 --outputPath $OUT_PATH/rupi --outputFormat plainText --suffix $5 --extension $6 --param country=$2 disabled=$3 corrected=$4 --encoding $ENCODING
}
export -f createRupi

function createCountry() {
# $1 Land (Switzerland, Germany, etc.)
# $2 Kürzel des Landes (CH, DE, etc.)
  createRupi Traditional $1 0 "" $2_ .csv
  createRupi Traditional $1 0 1 $2_ _Corr.csv
  createRupi Traditional $1 1 "" $2_ _Disa.csv
  createRupi Multi $1 0 "" $2_ .csv
  createRupi Multi $1 0 1 $2_ _Corr.csv
  createRupi Multi $1 1 "" $2_ _Disa.csv
  createRupi Unknown $1 0 "" $2_ .csv
  createRupi Unknown $1 0 1 $2_ _Corr.csv
  createRupi Unknown $1 1 "" $2_ _Disa.csv
}
export -f createCountry

# parallel --delay 1 -j $TASKS -u doit ::: E8_Nord E7_Nord E5_6 E9_10 E7_8_Sued
# parallel --delay 1 -j $TASKS -u doit ::: UserFlagOst UserFlagWest

parallel --delay 1 -j $TASKS -u createCountry ::: Switzerland Germany France :::+ CH DE FR
#createCountry Switzerland CH
#createCountry Germany DE
#createCountry France FR
