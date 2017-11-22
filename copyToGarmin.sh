#!/bin/sh
cp -pv output/*.ggz /Volumes/GARMIN/Garmin/GGZ/
cp -pv output/*.gpi /Volumes/GARMIN/Garmin/POI

diskutil unmount /dev/disk2
diskutil unmount /dev/disk3s1

find /Volumes/GARMIN -name '*.DS_Store' -type f -delete
find /Volumes/NONAME -name '*.DS_Store' -type f -delet

sudo rm -rf ~/.Trash
sudo rm -rf /Volumes/*/.Trashes
