#!/bin/sh
# Kopiert die POI Dateien in der Reihenfolge in das POI Verzeichnis
# in der man die POIs auf dem Gerät sehen möchte!

cd `dirname $0`
./mountGarmin.sh
cd /mnt/g/Garmin

# Zuerst alle GPI Dateien vom POI Verzeichnis ins POS_Stash Verzeichnis verschieben
mv POI/*.gpi POI_Stash/

# Und nun einzeln und in der richtigen Reihenfolge wieder zurück
for file in POI_Stash/*.gpi
do
#  echo $file
  mv $file POI
done
