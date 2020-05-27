#!/bin/sh

./mountGarmin.sh

rsync -verbose --recursive --size-only --delete /mnt/c/Geo/Spoilers/GeocachePhotos/ /mnt/g/Garmin/GeocachePhotos/
