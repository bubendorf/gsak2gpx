#!/bin/bash
DB=/Users/mbu/ExtDisk/Geo/GSAK8/data/Default/sqlite.db3

if [ "clear" = "$1" ]
then
  # Erst mal das UserFlag fuer alle Caches loeschen
  echo "UserFlags werden zurueck gesetzt!"
  sqlite3 $DB 'update Caches set UserFlag = 0;'
fi

# Und nun das UserFlag bei den wichtigen Caches setzen
sqlite3 $DB <selectMainCaches.sql
