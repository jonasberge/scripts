#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

echo 0 > /sys/devices/system/cpu/cpufreq/boost

ryzenadj \
	--stapm-limit=14000 \
	--fast-limit=16000 \
	--slow-limit=15000 \
	--tctl-temp=80

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Disable this temporarily
# as it seems to be causing problems.
exec "$DIR/fan.sh"
