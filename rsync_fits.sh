#!/bin/bash -eu
[ -n "${1:-}" ]
[ -n "${2:-}" ]
[ -d "$2" ] || mkdir -p "/media/nasastro/Astro/$2"
bw=600
find ./Documents/$1/ -name '*.fits' -printf '%Ts\t%p\n' | sort -nr | cut -f2 | while read -r f
do
	d="/media/nasastro/Astro/$2"
	echo "[${bw}KBps] '$(basename $f)' --> '$d'"
	rsync -avP --bwlimit "${bw}" --no-o --no-g --remove-source-files "$f" "$d/$(basename $f)"
done
