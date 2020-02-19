#!/bin/sh

# Kopiert die *ggz und *gpi Dateien auf das Garmin Oregon 700 welches unter G: bzw. /mnt/g gemounted sein muss.
# Das Garmin wird anschliessend 'ausgeworfen'.

while [ ! -d "/mnt/g/Garmin" ]
do
  sudo mount -t drvfs G: /mnt/g 2>/dev/null
  echo "Waiting for Garmin Oregon on /mnt/g/..."
  sleep 2
done

rm -f /mnt/g/Garmin/GGZ/*.ggz
#CPOPTS="--preserve=timestamps"
cp -v $CPOPTS output/ggz/*.ggz /mnt/g/Garmin/GGZ/ &

rm -f /mnt/g/Garmin/POI/*.gpi
rm -f /mnt/g/Garmin/POI_Stash/*.gpi
cp -v $CPOPTS output/gpi/*.gpi /mnt/g/Garmin/POI &

wait

sudo umount /mnt/g
/mnt/c/Users/Markus/Programme/UweSieber/RemoveDrive/x64/RemoveDrive.exe G:
