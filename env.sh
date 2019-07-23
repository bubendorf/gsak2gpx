#!/bin/bash
if [ -f /cygdrive/c/Users/Markus/AppData/Roaming/GSAK8/data/Default/sqlite.db3 ]
then
# Seems we are on Gala
  export BASE=/cygdrive/c/src/Kotlin/gsak2gpx
  export DB=/cygdrive/c/Users/Markus/AppData/Roaming/GSAK8/data/Default/sqlite.db3
#  export DB2=/cygdrive/c/Users/Markus/AppData/Roaming/GSAK8/data/RoadTrip/sqlite.db3
#  export DB=/cygdrive/c/Users/Markus/AppData/Roaming/GSAK8/data/Test/sqlite.db3
  export SQL_EXT=/cygdrive/c/src/cygwin/sqlitefunctions/libsqlitefunctions.dll
  export ICON_PATH=/cygdrive/c/Users/Markus/AppData/Roaming/GSAK8/Sygic/Icons
  export CYG2DOS="cygpath -w "
  export SYNCTHING_KEY="oxxZbivHdtmzKHYbwS2vFwSSGQJQPUfM"
  export SYGIC_PATH=/cygdrive/c/Users/Markus/Sync/Sygic/rupi
  DATE=date
  TASKS=8
  export GSAK8_INST=/cygdrive/c/Geo/GSAK8
  export GPSBABEL=$GSAK8_INST/gpsbabel.exe
else
  if [ -f /home/mbu/GSAK8/data/Default/sqlite.db3 ]
  then
  # Seems we are on N042/N020
    export BASE=/home/mbu/src/gsak2gpx
    export DB=/home/mbu/GSAK8/data/Default/sqlite.db3
    export SQL_EXT=/home/mbu/src/gsak2gpx/lib/libsqlitefunctions
    export ICON_PATH=/home/mbu/src/gsak2gpx/Icons
	export CYG2DOS="echo "
	export SYGIC_PATH=$HOME/Sync/Sygic/rupi
    DATE=date
    TASKS=2
  export GPSBABEL=~/bin/gpsbabel
  else
  # Seems we are on the Mac
    export BASE=/Users/mbu/src/gsak2gpx
    export DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3
    export SQL_EXT=/Users/mbu/src/gsak2gpx/lib/libsqlitefunctions.dylib
    export ICON_PATH=/Users/mbu/ExtDisk/Geo/GSAK8/Sygic/Icons
	export CYG2DOS="echo "
	export SYNCTHING_KEY="2TGSSVxpbaogJ5rQ7hAajHk6ebfUQGRf"
    export SYGIC_PATH=$HOME/Sync/Sygic/rupi
    DATE=gdate
    TASKS=6
  export GPSBABEL=~/bin/gpsbabel
  fi
fi

# Die zu verwendente sqlite Version
SQLITE=sqlite3

# export GPSBABEL=/usr/local/bin/gpsbabel
export CAT_PATH="categories/ggz categories/cachepoi categories/attributepoi categories/include"
export OUT_PATH=output
export GGZ_PATH=$OUT_PATH/ggz
export GPI_PATH=$OUT_PATH/gpi
export POIGPX_PATH=$OUT_PATH/cachepoi
export GGZGPX_PATH=$OUT_PATH/gpx
export RUPI_PATH=$OUT_PATH/rupi
export SYGIC_R4D4_PATH=$OUT_PATH/SygicR4D4
export SYGIC_R7D7_PATH=$OUT_PATH/SygicR7D7
export SYGIC_R8D8_PATH=$OUT_PATH/SygicR8D8
export CSV_PATH=$OUT_PATH/csv
#export JAR=target/gsak2gpx-1.3.2.jar
export JAR=build/libs/gsak2gpx-1.4.2-all.jar
export RUPI_JAR=../rupi/build/libs/rupi-1.2.2-all.jar

mkdir -p $OUT_PATH
mkdir -p $GGZ_PATH
mkdir -p $GPI_PATH
mkdir -p $POIGPX_PATH
mkdir -p $GGZGPX_PATH
mkdir -p $RUPI_PATH
mkdir -p $CSV_PATH
mkdir -p $SYGIC_R4D4_PATH
mkdir -p $SYGIC_R7D7_PATH
