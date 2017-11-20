#!/bin/sh
cp -pv output/*.ggz /Volumes/GARMIN/Garmin/GGZ/
cp -pv output/*.gpi /Volumes/GARMIN/Garmin/POI

diskutil unmount /dev/disk2
diskutil unmount /dev/disk3s1

