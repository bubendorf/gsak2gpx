#!/bin/bash
. ./env.sh

echo "Lösche Tour3 Flags von $DB"
sqlite3 $DB 'update custom set Tour3 = 0;'
