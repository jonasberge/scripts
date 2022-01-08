#!/bin/bash

source "$(dirname $0)/.env"

while :; do
	echo "[INFO] waiting for device $DEVICE_SERIAL..."
	adb -s "$DEVICE_SERIAL" wait-for-device
	gnirehtet run -s "$DEVICE_SERIAL" -d "$DNS_SERVERS_CSV" &
	adb -s "$DEVICE_SERIAL" wait-for-disconnect;
	echo "[INFO] device $DEVICE_SERIAL disconnected."
	kill "$!"
done

