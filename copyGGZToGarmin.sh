#!/bin/sh

# Kopiert die *ggz Dateien auf das Garmin Oregon 700 welches unter /Volumes/GARMIN gemounted sein muss.
# Das Garmin wird anschliessend 'ausgeworfen'.

rm -f /Volumes/GARMIN/Garmin/GGZ/*.ggz
cp -pv output/ggz/*.ggz /Volumes/GARMIN/Garmin/GGZ/

find /Volumes/GARMIN -name '*.DS_Store' -type f -delete
find /Volumes/NO\ NAME -name '*.DS_Store' -type f -delete

sudo rm -rf ~/.Trash
sudo rm -rf /Volumes/*/.Trashes

diskutil unmountDisk /dev/disk2
diskutil unmountDisk /dev/disk3
diskutil eject /dev/disk2
diskutil eject /dev/disk3
