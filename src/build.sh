#!/bin/bash

DEBUG="-debug=true"

mxmlc $DEBUG -compiler.source-path=flash flash/ichigo/Main.as && \
mv flash/ichigo/Main.swf web/latest.swf



