#!/bin/sh

if [ ! -d "/mnt/g/Garmin" ]
then
  sudo mount -t drvfs G: /mnt/g 2>/dev/null
  sudo mount -t drvfs H: /mnt/h 2>/dev/null
  sleep 0.2
  while [ ! -d "/mnt/g/Garmin" ]
  do
    echo "Waiting for Garmin Oregon on /mnt/g/ and /mnt/h/ ..."
    sleep 1
    sudo mount -t drvfs G: /mnt/g 2>/dev/null
    sudo mount -t drvfs H: /mnt/h 2>/dev/null
  done
fi
