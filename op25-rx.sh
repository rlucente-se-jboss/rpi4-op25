#!/usr/bin/env bash

HOSTIP=$(ip route get 8.8.8.8 | sed 's/..*src //g' | awk '{print $1; exit}')
PORT=8080

cd ~/rpi4-op25
cp op25.liq meta.json trunk.tsv fcso.tsv ~/op25/op25/gr-op25_repeater/apps

cd ~/op25/op25/gr-op25_repeater/apps

#
# The options are:
#
# --nocrypt                # silence encrypted traffic
# --args "rtl"             # Use RTL2832U chipset usb dongle
# --gains 'lna:36'         # gain setting
# -S 960000                # source sample rate
# -q 0                     # frequency correction in steps of 1200 Hz
# -d 0                     # fine tuning
# -X                       # enable experimental frequency error tracking
# -v 1                     # message debug level
# -2                       # enable phase2 tdma decode
# -T trunk.tsv             # trunk config file name
# -V                       # voice coded
# -w                       # output data to wireshark (enables liquidsoap to connect)
# -M meta.json             # Icecast Metadata Config File
# -l http:$HOSTIP:$PORT    # http terminal type
#

./rx.py \
    --nocrypt \
    --args "rtl" \
    --gains 'lna:36' \
    -S 960000 \
    -q 0 \
    -d 0 \
    -X \
    -v 1 \
    -2 \
    -T trunk.tsv \
    -V \
    -w \
    -M meta.json \
    -l http:$HOSTIP:$PORT \
    2> stderr-stream0.2

