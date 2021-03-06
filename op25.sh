#!/usr/bin/env bash

HOSTIP=$(ip route get 8.8.8.8 | sed 's/..*src //g' | awk '{print $1; exit}')
PORT=8080

cp op25.liq meta.json trunk.tsv fcso.tsv ~/op25/op25/gr-op25_repeater/apps

cd ~/op25/op25/gr-op25_repeater/apps

#
# The options are:
#
# --nocrypt                # silence encrypted traffic
# --args "rtl"             # Use RTL2832U chipset usb dongle
# -gains 'lna:36'          # gain setting
# -S 960000                # source sample rate
# -X                       # enable experimental frequency error tracking
# -q 0                     # frequency correction in steps of 1200 Hz
# -d 0                     # fine tuning
# -v 1                     # message debug level
# -2                       # enable phase2 tdma decode
# -V                       # voice coded
# -U                       # enable built-in udp audio player
# -T trunk.tsv             # trunk config file name
# -O pulse                 # use pulse audio for output
# -l http:$HOSTIP:$PORT    # http terminal type
#

./rx.py \
    --nocrypt \
    --args "rtl" \
    --gains 'lna:36' \
    -S 960000 \
    -X \
    -q 0 \
    -d 0 \
    -v 1 \
    -2 \
    -V \
    -U \
    -T trunk.tsv \
    -O pulse \
    -l http:$HOSTIP:$PORT \
    2> /dev/null

