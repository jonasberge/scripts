#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

function log {
	>&2 echo "$@"
}

function log_error {
	log "$@"
}

function log_state {
	log "state: $@"
}

TEMP_LABEL="Tctl"
TEMP_FILE_DIR=/sys/devices
TEMP_FILE_PATTERN="temp*_label"

function file_temp {
	for LABEL in $(find "$TEMP_FILE_DIR" -name "$TEMP_FILE_PATTERN"); do
		INPUT="${LABEL/%_label/_input}"
		if [ "$(cat "$LABEL")" == "$TEMP_LABEL" ]; then
			echo "$INPUT"
			break
		fi
	done
}

FILE_TEMP="$(file_temp)"
FILE_FAN=/proc/acpi/ibm/fan

FILE_PWM_MATCHES=(/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon*/pwm1)
FILE_PWM="${FILE_PWM_MATCHES[0]}"
FILE_PWM_ENABLE="${FILE_PWM}_enable"

if [ -z ${FILE_TEMP} ]; then
	log_error "could not find temperature file"
	exit 1
fi

echo temp: $FILE_TEMP
echo fan: $FILE_FAN
echo pwm: $FILE_PWM
echo pwm_enable: $FILE_PWM_ENABLE

SILENT_LEVEL=1
SILENT_LOOP_FREQ=0.5

MAIN_LOOP_FREQ=1

STATE_DISABLED=0
STATE_SILENT=1
STATE_NORMAL=2
STATE_AUTO=3

function set_state {
	case "$1" in
		$STATE_DISABLED)
			log_state "disabled"
			STATE=$STATE_DISABLED
			;;
		$STATE_SILENT)
			log_state "silent"
			STATE=$STATE_SILENT
			;;
		$STATE_NORMAL)
			log_state "normal"
			STATE=$STATE_NORMAL
			;;
		$STATE_AUTO)
			log_state "auto"
			STATE=$STATE_AUTO
			;;
		*)
			log_error "invalid state"
			exit 1
			;;
	esac
}

function pwm_manual {
	echo 1 > "$FILE_PWM_ENABLE"
}

function pwm_set {
	pwm_manual
	echo $1 > "$FILE_PWM"
}

function state_silent {
	if [ $STATE -eq $STATE_SILENT ]; then return; fi
	set_state $STATE_SILENT

	function loop {
		pwm_set "$SILENT_LEVEL"
		sleep "$SILENT_LOOP_FREQ"
	}

	(while :; do loop; done) & SILENT_PID=$!
}

function is_silent {
	if [ -z ${SILENT_PID+x} ]; then
		echo 0
	else
		echo 1
	fi
}

function kill_silent {
	if [ "$(is_silent)" -eq 1 ]; then
		kill $SILENT_PID
		unset SILENT_PID
	fi
}

function set_level {
	kill_silent
	echo "level $1" > "$FILE_FAN"
}

function state_disable {
	if [ $STATE -eq $STATE_DISABLED ]; then return; fi
	set_state $STATE_DISABLED

	set_level 0
}

function state_normal {
	if [ $STATE -eq $STATE_NORMAL ]; then return; fi
	set_state $STATE_NORMAL

	set_level 1
}

function state_auto {
	if [ $STATE -eq $STATE_AUTO ]; then return; fi
	set_state $STATE_AUTO

	set_level auto
}

function read_temp_raw {
	cat "$FILE_TEMP"
}

function read_temp {
	expr $(read_temp_raw) / 1000
}

function cleanup {
	log "cleaning up..."
	kill_silent
	set_level auto
}
trap cleanup EXIT

function initialize {
	pwm_set 0
}

STATE=$STATE_DISABLED
log_state "initialized"
initialize

LAST_TEMP="$(read_temp)"

while :; do
	TEMP="$(read_temp)"
	# echo "temp: $TEMP / $LAST_TEMP / $STATE"

	if [ $TEMP -lt 50 ]; then
		if [ $STATE -gt $STATE_DISABLED ] && [ $TEMP -ge 48 ]; then
			:
		else
			state_silent
		fi
	elif [ $TEMP -lt 60 ] || [ $LAST_TEMP -lt 60 ]; then
		if [ $STATE -gt $STATE_DISABLED ] && [ $TEMP -ge 56 ]; then
			:
		else
			state_silent
		fi
	elif [ $TEMP -lt 68 ] || [ $LAST_TEMP -lt 68 ]; then
		if [ $STATE -gt $STATE_NORMAL ] && [ $TEMP -ge 64 ]; then
			:
		else
			state_normal
		fi
	else
		state_auto
	fi

	LAST_TEMP="$TEMP"
	sleep "$MAIN_LOOP_FREQ"
done
