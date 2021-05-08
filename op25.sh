#!/usr/bin/env bash

HOSTIP=$(ip route get 8.8.8.8 | sed 's/..*src //g' | awk '{print $1; exit}')
PORT=8080

cd /home/pi/op25/op25/gr-op25_repeater/apps

#
# The options are:
#
# --args 'rtl'                  # Use RTL2832U chipset usb dongle
# -N 'LNA:30'                   # gain setting
# -S 2500000                    # source sample rate
# -x 2                          # audio gain
# -f 854.9875e6                 # USRP center frequency
# -o 17e3                       # tuning offset frequency [to circumvent DC offset]
# -q 0                          # frequency correction in steps of 1200 Hz
# -d 0                          # fine tuning in steps of 100 Hz
# -T trunk.tsv                  # trunk config file name
# -V                            # voice coded
# -2                            # enable phase2 tdma decode
# -U                            # enable built-in udp audio player
# -O hw:CARD=Headphones,DEV=0   # 3.5mm audio jack as output
# -l http:$HOSTIP:$PORT         # http terminal type
#

./rx.py \
    --args 'rtl' \
    -N 'LNA:30' \
    -S 2500000 \
    -x 2 \
    -f 854.9875e6 \
    -o 17e3 \
    -q 0 \
    -d 0 \
    -T trunk.tsv \
    -V \
    -2 \
    -U \
    -O hw:CARD=Headphones,DEV=0 \
    -l http:$HOSTIP:$PORT
    2> stderr-stream0.2

