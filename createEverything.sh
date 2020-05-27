#!/bin/sh

./createPOIs.sh &
sleep 1

./createGGZ.sh &
sleep 1

./createCachePOIs.sh &

wait
