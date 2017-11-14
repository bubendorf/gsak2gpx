#!/bin/sh

./createCacheGGZ.sh &
sleep 5

./createPOIs.sh
./createCachePOIs.sh

wait

