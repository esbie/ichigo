#!/bin/bash

DEBUG="-debug=true"
VERSION="-target-player=10.0.0"
OUT="-o=web/latest.swf"

mxmlc $DEBUG $VERSION $OUT -compiler.source-path=flash flash/ichigo/Main.as
