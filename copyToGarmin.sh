#!/bin/sh

# Kopiert die *ggz und *gpi Dateien auf das Garmin Oregon 700 welches unter G: bzw. /mnt/g gemounted sein muss.
# Das Garmin wird anschliessend 'ausgeworfen'.

./mountGarmin.sh

#MNT=/mnt
MNT=/cygdrive

#RSYNC=rsync
RSYNC=/mnt/c/cygwin64/bin/rsync.exe

#UNISON=unison
UNISON=/mnt/c/cygwin64/bin/unison-2.51.exe

#RSYNC_OPTS="--size-only --modify-window=60"
RSYNC_OPTS="--archive --modify-window=60"

echo "GeocachePhotos"
NUM_NEW_FILES=$(find /mnt/c/Geo/Spoilers/GeocachePhotos/ -type d -mtime -1 | wc -l)
echo "Anzahl verändeter Verzeichnisse: $NUM_NEW_FILES"
if [ $NUM_NEW_FILES -gt 0 ]
then
  $RSYNC --recursive $RSYNC_OPTS --delete  \
      $MNT/c/Geo/Spoilers/GeocachePhotos/ $MNT/g/Garmin/GeocachePhotos/
fi

echo "GGZ Dateien"
$RSYNC --delete --recursive --verbose $RSYNC_OPTS output/ggz/ $MNT/g/Garmin/GGZ/
#rm -f /mnt/g/Garmin/GGZ/*.ggz
#cp -v -u output/ggz/*.ggz /mnt/g/Garmin/GGZ/ &

echo "POI Dateien"
$RSYNC -verbose --delete --recursive $RSYNC_OPTS output/gpi/ $MNT/g/Garmin/POI/
rm -f /mnt/g/Garmin/POI_Stash/*.gpi
#rm -f /mnt/g/Garmin/POI/*.gpi
#cp -g -v -u output/gpi/*.gpi /mnt/g/Garmin/POI/

#echo "VeloSwitzerland"
#$RSYNC --verbose $RSYNC_OPTS \
#      $MNT/c/Garmin/velomap/switzerland/veloSwitzerland.img \
#      $MNT/h/Garmin/veloSwitzerland.img
echo "Map Bubendorf.img"
$RSYNC --verbose --size-only $RSYNC_OPTS --progress \
      $MNT/c/Garmin/data/Bubendorf.img \
      $MNT/h/Garmin/Bubendorf.img


echo "Sync GPX Ordner"
$UNISON GarminGPX

wait
./sortPOIs.sh
sleep 0.3
./umountGarmin.sh
