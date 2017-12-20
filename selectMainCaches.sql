-- Die Extension fuer diverse Funktionen (cos(), sqrt(), etc.) laden
SELECT load_extension('/Users/mbu/src/gsak2gpx/lib/libsqlitefunctions.dylib');

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
