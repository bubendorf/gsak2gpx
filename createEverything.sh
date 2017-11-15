#!/bin/sh

./createCacheGGZ.sh &
sleep 2

./createPOIs.sh &
sleep 1

./createCachePOIs.sh

wait

