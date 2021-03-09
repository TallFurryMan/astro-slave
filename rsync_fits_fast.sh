#!/bin/bash -eux
[ -n "${1:-}" ]
[ -n "${2:-}" ]
[ -d "$2" ] || mkdir -p "/media/nasastro/Astro/$2"
find ./Documents/$1/ -name '*.fits' | while read -r f ; do rsync -avP --remove-source-files $f /media/nasastro/Astro/$2/$(basename $f) ; done
