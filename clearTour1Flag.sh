#!/bin/bash
. ./env.sh

echo "Lösche Tour1 Flags von $DB"
sqlite3 $DB 'update custom set Tour1 = 0;'
