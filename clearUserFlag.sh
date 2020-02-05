#!/bin/bash
. ./env.sh

echo "Lösche UserFlag Flags von $DB"
sqlite3 $DB 'update caches set UserFlag = 0;'
