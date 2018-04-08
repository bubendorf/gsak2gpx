#!/bin/bash

# Erzeugt die RUPI Dateien

export OPTS="-XX:+UseParallelGC -Xmx1500M -Dorg.slf4j.simpleLogger.defaultLogLevel=info"
. ./env.sh

export ENCODING=iso8859-1
export CAT_PATH="$BASE/categories/rupi $BASE/categories/include"

function createCSV() {
# $1 Name der Kategorie
# $2 Land
# $3 0=Enabled, 1=Disabled, Leer=Egal
# $4 0=Ohne Corrected Coordinates, 1=Mit Corrected Coordinates, Leer=Egal
# $5 Suffix der erzeugten Datei
# $6 Extension der erzeugten Datei
  java $OPTS -jar $JAR --database $DB --categoryPath $CAT_PATH --categories $1 --outputPath $CSV_PATH --outputFormat plainText --suffix $5 --extension $6 --param country=$2 disabled=$3 corrected=$4 --encoding $ENCODING
  FILENAME=$CSV_PATH/$5$1$6
#  echo $FILENAME
  actualsize=$(stat -c%s $FILENAME)
  minimumsize=15
  if [ $actualsize -lt $minimumsize ]
  then
    echo "File $FILENAME is too small ==> Deleting"
    rm $FILENAME
  fi
}
export -f createCSV

#createCSV Parking Switzerland "" "" CH_ _Parking.csv
#createCSV Traditional France  $1 0 1 FR_ _Corr.csv
#exit 0

function createCountry() {
# $1 Land (Switzerland, Germany, etc.)
# $2 Kürzel des Landes (CH, DE, etc.)
  createCSV Parking $1 "" "" $2_ .csv
  createCSV Traditional $1 0 "" $2_ .csv
  createCSV Traditional $1 0 1 $2_ _Corr.csv
  createCSV Traditional $1 1 "" $2_ _Disa.csv
  createCSV Multi $1 0 "" $2_ .csv
  createCSV Multi $1 0 1 $2_ _Corr.csv
  createCSV Multi $1 1 "" $2_ _Disa.csv
  createCSV Unknown $1 0 "" $2_ .csv
  createCSV Unknown $1 0 1 $2_ _Corr.csv
  createCSV Unknown $1 1 "" $2_ _Disa.csv
}
export -f createCountry

function convertToRupi() {
# $1 Name der Kategorie bzw. des Teilnames der Dateien
  java -jar $RUPI_JAR -n $1 -o $RAWRUPI_PATH $CSV_PATH/*$1.csv
  cp $ICON_PATH/$1.bmp $RAWRUPI_PATH
}
export -f convertToRupi

#parallel --delay 1 -j $TASKS -u createCountry ::: Switzerland Germany France Netherlands Liechtenstein Austria Italy :::+ CH DE FR NL LI AT IT
#parallel -j $TASKS -u convertToRupi ::: Parking Traditional Traditional_Corr Traditional_Disa Multi Multi_Corr Multi_Disa Unknown Unknown_Corr Unknown_Disa

mkdir -p $RUPI_PATH/aut
rm -f $RUPI_PATH/aut/*
ln $RAWRUPI_PATH/AT_* $RUPI_PATH/aut

mkdir -p $RUPI_PATH/che
rm -f $RUPI_PATH/che/*
ln $RAWRUPI_PATH/CH_* $RUPI_PATH/che

mkdir -p $RUPI_PATH/deu01
rm -f $RUPI_PATH/deu01/*
ln $RAWRUPI_PATH/DE_* $RUPI_PATH/deu01

mkdir -p $RUPI_PATH/deu03
rm -f $RUPI_PATH/deu03/*
ln $RAWRUPI_PATH/DE_* $RUPI_PATH/deu03

mkdir -p $RUPI_PATH/fra01
rm -f $RUPI_PATH/fra01/*
ln $RAWRUPI_PATH/FR_* $RUPI_PATH/fra01

mkdir -p $RUPI_PATH/fra07
rm -f $RUPI_PATH/fra07/*
ln $RAWRUPI_PATH/FR_* $RUPI_PATH/fra07

mkdir -p $RUPI_PATH/fra08
rm -f $RUPI_PATH/fra08/*
ln $RAWRUPI_PATH/FR_* $RUPI_PATH/fra08

mkdir -p $RUPI_PATH/ita02
rm -f $RUPI_PATH/ita02/*
ln $RAWRUPI_PATH/IT_* $RUPI_PATH/ita02

mkdir -p $RUPI_PATH/ita03
rm -f $RUPI_PATH/ita03/*
ln $RAWRUPI_PATH/IT_* $RUPI_PATH/ita03

mkdir -p $RUPI_PATH/lie
rm -f $RUPI_PATH/lie/*
ln $RAWRUPI_PATH/LI_* $RUPI_PATH/lie

mkdir -p $RUPI_PATH/nid
rm -f $RUPI_PATH/nid/*
ln $RAWRUPI_PATH/NL_* $RUPI_PATH/nid

#convertToRupi Traditional
#convertToRupi Traditional_Corr
#convertToRupi Traditional_Disa
