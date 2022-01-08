#!/bin/bash

COMMAND=scrcpy

args=(
	--window-title Smartphone
	--window-borderless
	--serial=RF8M30RRFKJ
	--prefer-text
	--window-height 1058 --window-x 1419
)

READ_ONLY=0

for arg in "$@"; do
	if [ "$arg" == "-n" ]; then
		READ_ONLY=1
	elif [ "$arg" == "--help" ]; then
		exec "$COMMAND" --help
	fi
done

if [ -z "$READ_ONLY" ]; then
	args+=(-S)
	args+=(-w)
fi

set -x

"$COMMAND" "${args[@]}" $@
