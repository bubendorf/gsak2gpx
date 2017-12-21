#!/bin/bash
. ./env.sh

if [ "-h" = "$1" ]
then
  echo "Usage: selectMainCaches.sh [clear] [lat lon radiusInKm]"
  exit 1
fi

if [ "clear" = "$1" ]
then
  # Erst mal das UserFlag fuer alle Caches loeschen
  echo "UserFlags werden zurueck gesetzt!"
  sqlite3 $DB 'update Caches set UserFlag = 0;'
  shift
fi

# Falls nun eine Koordinate und ein Radius in der Kommandozeile ist
# dann werden die Caches um diesen Punkt herum ausgewaehlt.
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
  echo "Zusaetzliche Caches aufgrund der Parameter:"
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
echo "Total Caches:"
sqlite3 $DB <<HierBeginntUndEndetDasSQL
-- Die Extension fuer diverse Funktionen (cos(), sqrt(), etc.) laden
SELECT load_extension('$SQL_EXT');

-- Eine 'Variable' erstellen mit der man die Radien dynamisch machen kann
CREATE TEMP TABLE IF NOT EXISTS Variables (Name TEXT PRIMARY KEY, Value TEXT);
INSERT OR REPLACE INTO Variables VALUES ('Faktor', 0.8);

-- Caches um Wangen herum (cos(47.23468) ==> 0.678997); 75km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.23468)*111.195) + square((longitude - 7.65588)*111.195*0.678997)) <= 75 * (SELECT Value FROM Variables WHERE Name = 'Faktor')
and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;

-- Caches um Bern herum (cos = 0.68266); 30km
update caches
set UserFlag = 1
where sqrt(square((latitude - 46.94798)*111.195) + square((longitude - 7.44743)*111.195*0.68266)) <= 30 * (SELECT Value FROM Variables WHERE Name = 'Faktor')
and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;

-- Caches um Basel herum; 60km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.55814)*111.195) + square((longitude - 7.58769)*111.195*0.67484)) <= 60 * (SELECT Value FROM Variables WHERE Name = 'Faktor')
and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;

-- Caches um Olten herum; 60km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.35333)*111.195) + square((longitude - 7.907785)*111.195*0.67748)) <= 60 * (SELECT Value FROM Variables WHERE Name = 'Faktor')
and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;

-- Caches um Lenzburg herum; 50km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.38735)*111.195) + square((longitude - 8.18034)*111.195*0.67704)) <= 50 * (SELECT Value FROM Variables WHERE Name = 'Faktor')
and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;

-- Caches um Zuerich herum; 30km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.37174)*111.195) + square((longitude - 8.54226)*111.195*0.67724)) <= 30 * (SELECT Value FROM Variables WHERE Name = 'Faktor')
and (CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0;

select count(*) from caches where UserFlag=1;

HierBeginntUndEndetDasSQL