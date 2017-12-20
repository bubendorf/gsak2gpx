#!/bin/bash
. ./env.sh

if [ "clear" = "$1" ]
then
  # Erst mal das UserFlag fuer alle Caches loeschen
  echo "UserFlags werden zurueck gesetzt!"
  sqlite3 $DB 'update Caches set UserFlag = 0;'
  shift
fi

# Falls nun eine Koordinate und ein Radius in der Kommandozeile ist
# dann werden die Caches um diesen Punkt herum ausgewa√aehlt.
if [ "$#" -eq 3 -o "$#" -eq 5 ]
then
  LAT=$1
  LON=$2
  RADIUS=$3
  if [ "$#" -eq 5 ]
  then
    LAT=$(bc <<< "scale=5; $1 + $2/60.0")
    LON=$(bc <<< "scale=5; $3 + $4/60.0")
    RADIUS=$5
  fi

  echo "Selektierere Caches im Radius von ${RADIUS}km rund um lat=$LAT lon=$LON herum."
  sqlite3 $DB <<HierBeginntUndEndetDasSQL
  SELECT load_extension('$SQL_EXT');
  update caches
    set UserFlag = 1
    where sqrt(square((latitude - $LAT)*111.195) + square((longitude - $LON)*111.195*cos($LAT / 57.29578))) <= $RADIUS
    and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;
  select count(*) from caches where UserFlag=1;
HierBeginntUndEndetDasSQL

fi


# Und nun das UserFlag bei den wichtigen Caches setzen
sqlite3 $DB <selectMainCaches.sql
