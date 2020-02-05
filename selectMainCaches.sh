#!/bin/bash
. ./env.sh

if [ "-h" = "$1" ]
then
  echo "Usage: selectMainCaches.sh [-clear] [-factor f] [-spoiler] [lat lon radiusInKm]"
  exit 1
fi

if [ "-clear" = "$1" ]
then
  # Erst mal das UserFlag fuer alle Caches loeschen
  echo "UserFlags werden zurueck gesetzt!"
  sqlite3 $DB <<SQLCodeSQLCode
.once /dev/null
PRAGMA journal_mode=memory;
update Caches set UserFlag = 0;
SQLCodeSQLCode
  shift
fi

FAKTOR=0.8
if [ "-factor" = "$1" -a -n "$2" ]
then
  FAKTOR=$2
  shift
  shift
fi
echo "Verwende einen Faktor von $FAKTOR"

if [ "-spoiler" = "$1" ]
then
  COMMON_WHERE="Archived = 0 and Found = 0"
  shift
else
  COMMON_WHERE="(CacheType <> 'U' or HasCorrected) and Archived = 0 and TempDisabled = 0 and Found = 0"
fi
COMMON_WHERE="$COMMON_WHERE and ((CacheType <> 'E' and CacheType <> 'C' and CacheType <> 'Z') or (PlacedDate > date('now','-1 day') and PlacedDate < date('now','+14 day')))"

# Falls nun eine Koordinate und ein Radius in der Kommandozeile ist
# dann werden die Caches um diesen Punkt herum ausgewaehlt.
if [ "$#" -eq 3 -o "$#" -eq 5 ]
then
  LAT=$(echo $1 | tr -d 'NE°')
  LON=$(echo $2 | tr -d 'NE°')
  RADIUS=$3
  if [ "$#" -eq 5 ]
  then
    LON=$(echo $3 | tr -d 'NE°')
    LAT=$(bc <<< "scale=5; $LAT + $2/60.0")
    LON=$(bc <<< "scale=5; $LON + $4/60.0")
    RADIUS=$5
  fi

  echo "Selektierere Caches im Radius von ${RADIUS}km rund um lat=$LAT lon=$LON herum."
  echo -n "Zusaetzliche Caches aufgrund der Parameter: "
  sqlite3 $DB <<HierBeginntUndEndetDasSQL
.output /dev/null
SELECT load_extension('$SQL_EXT');
PRAGMA journal_mode=memory;
.output
update caches
  set UserFlag = 1
  where sqrt(square((latitude - $LAT)*111.195) + square((longitude - $LON)*111.195*cos($LAT / 57.29578))) <= $RADIUS
  and $COMMON_WHERE;
select count(*) from caches where UserFlag=1;
HierBeginntUndEndetDasSQL
elif [ "$#" -ne 0 ]
then
  echo "Usage: selectMainCaches.sh [clear] [-factor f]  [lat lon radiusInKm]"
  exit 1
fi

DIST_WANGEN=75
DIST_BERN=30
DIST_BASEL=60
DIST_OLTEN=60
DIST_LENZBURG=30
DIST_ZUERICH=0

# Und nun das UserFlag bei den wichtigen Caches setzen
echo -n "Total Caches: "
sqlite3 $DB <<HierBeginntUndEndetDasSQL
-- Die Extension fuer diverse Funktionen (cos(), sqrt(), etc.) laden
.output /dev/null
SELECT load_extension('$SQL_EXT');
PRAGMA journal_mode=memory;
.output

-- Caches um Wangen herum (cos(47.23468) ==> 0.678997); 75km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.23468)*111.195) + square((longitude - 7.65588)*111.195*0.678997)) <= $DIST_WANGEN * $FAKTOR
and $COMMON_WHERE;

-- Caches um Bern herum (cos = 0.68266); 30km
update caches
set UserFlag = 1
where sqrt(square((latitude - 46.94798)*111.195) + square((longitude - 7.44743)*111.195*0.68266)) <= $DIST_BERN * $FAKTOR
and $COMMON_WHERE;

-- Caches um Basel herum; 60km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.55814)*111.195) + square((longitude - 7.58769)*111.195*0.67484)) <= $DIST_BASEL * $FAKTOR
and $COMMON_WHERE;

-- Caches um Olten herum; 60km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.35333)*111.195) + square((longitude - 7.907785)*111.195*0.67748)) <= $DIST_OLTEN * $FAKTOR
and $COMMON_WHERE;

-- Caches um Lenzburg herum; 50km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.38735)*111.195) + square((longitude - 8.18034)*111.195*0.67704)) <= $DIST_LENZBURG * $FAKTOR
and $COMMON_WHERE;

-- Caches um Zuerich herum; 30km
update caches
set UserFlag = 1
where sqrt(square((latitude - 47.37174)*111.195) + square((longitude - 8.54226)*111.195*0.67724)) <= $DIST_ZUERICH * $FAKTOR
and $COMMON_WHERE;

select count(*) from caches where UserFlag=1;

HierBeginntUndEndetDasSQL
