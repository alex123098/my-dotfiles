#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset

hue=(-level "0%,100%,0.6")
effect=(-filter Gaussian -resize 20% -define "filter:sigma=1.5" -resize 500.5%)
font=$(convert -list font | awk "{ a[NR] = \$2 } /family: $(fc-match sans -f "%{family}\n")/ { print a[NR-1]; exit }")
image=$(mktemp --suffix=.png)
shot=(scrot --format png -o)
lock=(i3lock -i "${image}")

set -o pipefail
trap 'rm -f "$image"' EXIT

# take a screenshot
command -- "${shot[@]}" "${image}"
brightness=$(convert "${image}" -gravity center -crop 100x100+0+0 +repage -colorspace hsb -resize 1x1 txt:- |
	awk -F '[%$]' 'NR==2 { gsub(",", ""); printf "%.0f\n", $(NF-1)}')

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
icons_root="${script_dir}/icons"

if [[ $brightness -gt 60 ]]; then
	bw="black"
	icon="${icons_root}/lockdark.png"
	param=("--inside-color=0000001c" "--ring-color=0000003e"
		"--line-color=00000000" "--keyhl-color=ffffff80" "--ringver-color=ffffff00"
		"--separator-color=22222260" "--insidever-color=ffffff1c"
		"--ringwrong-color=ffffff55" "--insidewrong-color=ffffff1c"
		"--verif-color=ffffff00" "--wrong-color=ff000000" "--time-color=ffffff00"
		"--date-color=ffffff00" "--layout-color=ffffff00")
else
	bw="white"
	icon="${icons_root}/locklight.png"
	param=("--inside-color=ffffff1c" "--ring-color=ffffff3e"
		"--line-color=ffffff00" "--keyhl-color=00000080" "--ringver-color=00000000"
		"--separator-color=22222260" "--insidever-color=0000001c"
		"--ringwrong-color=00000055" "--insidewrong-color=0000001c"
		"--verif-color=00000000" "--wrong-color=ff000000" "--time-color=00000000"
		"--date-color=00000000" "--layout-color=00000000")
fi

convert "$image" "${hue[@]}" "${effect[@]}" -font "$font" -pointsize 26 -fill "$bw" -gravity center \
	-annotate +0+160 "Enter password or press [Enter] to use fingerprint to unlock" "$icon" -gravity center -composite "$image"

if ! "${lock[@]}" "${param[@]}" >/dev/null 2>&1; then
	"${lock[@]}"
fi
