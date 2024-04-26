#!/usr/bin/env bash

MON=$(xrandr | grep " connected" | cut -f 1 -d " ")
STEP=0.05
CUR_BR_PATH="${XDH_DATA_HOME:-$HOME/.local/share}/bright_up/cur_value"

BR_STR=$(xrandr --current --verbose | grep ^"$MON" -A5 | tail -n 1)
CUR_BR="${BR_STR##* }"

if [[ -z "$1" ]]; then
	echo "${CUR_BR}"
	exit 0
fi

if [[ "$1" == "apply" ]]; then
	NEW_BR=$(cat "${CUR_BR_PATH}")
	xrandr --output "${MON}" --brightness "${NEW_BR}"
	exit 0
fi

NEW_BR=CUR_BR
[[ "$1" == "up" || "$1" == "+" ]] && NEW_BR=$(echo "${CUR_BR}" + "${STEP}" | bc -l)
[[ "$1" == "down" || "$1" == "-" ]] && NEW_BR=$(echo "${CUR_BR}" - "${STEP}" | bc -l)
[[ "${NEW_BR:0:1}" == "-" ]] && NEW_BR=0.05
[[ "${NEW_BR:0:1}" == "1" ]] && NEW_BR=1.0
[[ $NEW_BR < 0.05 ]] && NEW_BR=0.05

# store new brightness value
echo "${NEW_BR}" >"${CUR_BR_PATH}"
xrandr --output "${MON}" --brightness "${NEW_BR}"
