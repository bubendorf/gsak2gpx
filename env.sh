#!/bin/bash
if [ -f /home/mbu/GSAK8/data/Default/sqlite.db3 ]
then
# Seems we are on N042
  export BASE=/home/mbu/src/gsak2gpx
  export DB=/home/mbu/GSAK8/data/Default/sqlite.db3
  export SQL_EXT=/home/mbu/src/gsak2gpx/lib/libsqlitefunctions
  export ICON_PATH=/home/mbu/src/gsak2gpx/Icons
  DATE=date
  TASKS=2
else
# Seems we are on the Mac
  export BASE=/Users/mbu/src/gsak2gpx
  export DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
  export SQL_EXT=/Users/mbu/src/gsak2gpx/lib/libsqlitefunctions.dylib
  export ICON_PATH=/Users/mbu/ExtDisk/Geo/GSAK8/Sygic/Icons
  DATE=gdate
  TASKS=6
fi

export CAT_PATH="$BASE/categories/ggz $BASE/categories/cachepoi $BASE/categories/attributepoi $BASE/categories/include"
export OUT_PATH=$BASE/output
export GPX_PATH=$OUT_PATH/cachepoi
export RUPI_PATH=$OUT_PATH/rupi
export SYGIC_R3D3_PATH=$OUT_PATH/SygicR3D3
export SYGIC_R7D7_PATH=$OUT_PATH/SygicR7D7
export CSV_PATH=$OUT_PATH/csv
export JAR=target/gsak2gpx-1.2.jar
export RUPI_JAR=../rupi/build/libs/rupi-1.2-all.jar

mkdir -p $OUT_PATH
mkdir -p $GPX_PATH
mkdir -p $RUPI_PATH
mkdir -p $CSV_PATH
mkdir -p $SYGIC_R3D3_PATH
mkdir -p $SYGIC_R7D7_PATH
