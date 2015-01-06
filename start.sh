#!/bin/sh

cd "`dirname "$0"`"

[ -z "$PYTHON3_BIN" ] && PYTHON3_BIN=$(which python3 2>/dev/null)

if [ ! -x "$PYTHON3_BIN" ]; then
	echo 'python3 not found.' >&2
	exit 1
fi

$PYTHON3_BIN avto-lux/main.py
