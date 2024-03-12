#!/usr/bin/env bash

MON=$(xrandr | grep " connected" | cut -f 1 -d " ")
STEP=0.05

BR_STR=$(xrandr --current --verbose | grep ^"$MON" -A5 | tail -n 1)
CUR_BR="${BR_STR##* }"

REAL=${CUR_BR%%"."*}
DEC=${CUR_BR#*"."}

NEW_BR=CUR_BR
[[ "$1" == "up" || "$1" == "+" ]] && NEW_BR=$(echo "${CUR_BR}" + "${STEP}" | bc -l)
[[ "$1" == "down" || "$1" == "-" ]] && NEW_BR=$(echo "${CUR_BR}" - "${STEP}" | bc -l)
[[ "${NEW_BR:0:1}" == "-" ]] && NEW_BR=0.05
[[ "${NEW_BR:0:1}" == "1" ]] && NEW_BR=1.0
[[ $NEW_BR < 0.05 ]] && NEW_BR=0.05

xrandr --output "${MON}" --brightness "${NEW_BR}"
