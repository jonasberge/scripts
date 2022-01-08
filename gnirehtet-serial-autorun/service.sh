#!/bin/bash

source "$(dirname $0)/.env"

while :; do
	echo "[INFO] waiting for device $DEVICE_SERIAL..."
	adb -s "$DEVICE_SERIAL" wait-for-device
	# start gnirehtet for work profile user
	adb shell am start --user 10 \
		-a com.genymobile.gnirehtet.START -n com.genymobile.gnirehtet/.GnirehtetActivity
	gnirehtet run -s "$DEVICE_SERIAL" -d "$DNS_SERVERS_CSV" &
	adb -s "$DEVICE_SERIAL" wait-for-disconnect;
	echo "[INFO] device $DEVICE_SERIAL disconnected."
	kill "$!"
done

