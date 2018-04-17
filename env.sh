#!/bin/bash
if [ -f /home/mbu/GSAK8/data/Default/sqlite.db3 ]
then
# Seems we are on N042
  export BASE=/home/mbu/src/gsak2gpx
  export DB=/home/mbu/GSAK8/data/Default/sqlite.db3
  export SQL_EXT=/home/mbu/src/gsak2gpx/lib/libsqlitefunctions
  DATE=date
  TASKS=2
else
# Seems we are on the Mac
  export BASE=/Users/mbu/src/gsak2gpx
  export DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
  export SQL_EXT=/Users/mbu/src/gsak2gpx/lib/libsqlitefunctions.dylib
  DATE=gdate
  TASKS=4
fi

export CAT_PATH="$BASE/categories/ggz $BASE/categories/cachepoi $BASE/categories/attributepoi $BASE/categories/include"
export OUT_PATH=$BASE/output
export GPX_PATH=$OUT_PATH/cachepoi
export RAWRUPI_PATH=$OUT_PATH/rawrupi
export RUPI_PATH=$OUT_PATH/rupi
export CSV_PATH=$OUT_PATH/csv
export JAR=target/gsak2gpx-1.2.jar
export RUPI_JAR=../rupi/target/rupi-1.1-SNAPSHOT-jar-with-dependencies.jar
export ICON_PATH=/Users/mbu/ExtDisk/Geo/GSAK8/Sygic/Icons

mkdir -p $OUT_PATH
mkdir -p $GPX_PATH
mkdir -p $RUPI_PATH
mkdir -p $RAWRUPI_PATH
mkdir -p $CSV_PATH
