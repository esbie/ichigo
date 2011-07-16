#!/bin/bash

DEBUG="-debug=true"
VERSION="-target-player=10.0.0"
OUT="-o=web/latest.swf"
MAIN="flash/ichigo/Main.as"

echo "mxmlc $DEBUG $VERSION $OUT -compiler.source-path=flash $MAIN"

sleep 5

while [ /usr/bin/true ]
do
  echo "compile 1"
  sleep 2
done
