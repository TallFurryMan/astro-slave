#!/bin/bash -eu
[ -n "${1:-}" ]
[ -n "${2:-}" ]
#bw=600
#dir="/media/nasastro/Astro"
bw=50000
dir="/media/astromaster/Documents"
find ./Documents/$1/ -name '*.fits' -mmin +1 -printf '%Ts\t%p\n' | sort -nr | cut -f2 | while read -r f
do
	d="$dir/$2"
	[ -d "$d" ] || mkdir -p "$d"
	echo "[${bw}KBps] '$(basename $f)' --> '$d'"
	rsync -avP --bwlimit "${bw}" --no-o --no-g --remove-source-files "$f" "$d/$(basename $f)"
done
