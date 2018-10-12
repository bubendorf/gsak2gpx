#!/bin/bash
. ./env.sh

echo "Lösche Tour2 Flags von $DB"
sqlite3 $DB 'update custom set Tour2 = 0;'
