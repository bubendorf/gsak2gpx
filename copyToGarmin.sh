#!/bin/sh

# Kopiert die *ggz und *gpi Dateien auf das Garmin Oregon 700 welches unter /Volumes/GARMIN gemounted sein muss.
# Das Garmin wird anschliessend 'ausgeworfen'.

rm /Volumes/GARMIN/Garmin/GGZ/*.ggz
cp -pv output/*.ggz /Volumes/GARMIN/Garmin/GGZ/ &

rm /Volumes/GARMIN/Garmin/POI/*.gpi
cp -pv output/*.gpi /Volumes/GARMIN/Garmin/POI &

wait

find /Volumes/GARMIN -name '*.DS_Store' -type f -delete
find /Volumes/NO\ NAME -name '*.DS_Store' -type f -delete

sudo rm -rf ~/.Trash
sudo rm -rf /Volumes/*/.Trashes

diskutil unmountDisk /dev/disk2
diskutil unmountDisk /dev/disk3
diskutil eject /dev/disk2
diskutil eject /dev/disk3
