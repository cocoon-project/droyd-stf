#!/bin/sh
export RF_HUB_URL=http://192.168.1.23:8005
#export RF_HUB_URL=
pybot -L trace -P ../ rf_phone_demo.txt

