#!/bin/sh

# Kopiert die *ggz und *gpi Dateien auf das Garmin Oregon 700 welches unter G: bzw. /cygdrive/g gemounted sein muss.
# Das Garmin wird anschliessend 'ausgeworfen'.

while [ ! -d "/cygdrive/g/Garmin" ]
do
  echo "Waiting for Garmin Oregon on /cygdrive/g ..."
  sleep 2
done

rm -f /cygdrive/g/Garmin/GGZ/*.ggz
cp -v --preserve=timestamps output/ggz/*.ggz /cygdrive/g/Garmin/GGZ/ &

rm -f /cygdrive/g/Garmin/POI/*.gpi
rm -f /cygdrive/g/Garmin/POI_Stash/*.gpi
cp -v --preserve=timestamps output/gpi/*.gpi /cygdrive/g/Garmin/POI &

wait

/cygdrive/c/Users/Markus/Programme/UweSieber/RemoveDrive/x64/RemoveDrive.exe G:
