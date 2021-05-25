#!/usr/bin/env bash

STREAM_URL="http://192.168.1.204:8000/op25"

mkdir -p ~/fcso
 
curl \
  --output ~/fcso/"$(TZ=America/New_York date +'%s_%Y_%m_%d_%H_%M').mp3" \
  $STREAM_URL --max-time 1860

