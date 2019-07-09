#!/bin/bash -eu

#cd /usr/share/astrometry

md5sums=

# This is for http://data.astrometry.net/4200/
baseurl="http://data.astrometry.net/4200"
md5sums="$md5sums $(wget -O- "$baseurl/md5sums.txt")"

# This is for http://data.astrometry.net/4100/ - no md5_sum.txt there
baseurl="http://data.astrometry.net/4100"
md5sums="$md5sums $(for i in $(seq 4107 4119) ; do echo "0 *index-${i}.fits" ; done)"

md5sums=$(printf "%s %s\n" $md5sums)

echo -e "$md5sums" | while read -r md5 index_file
do
	index_file=${index_file}
	echo "Checking '$index_file'..."
	if [ -e "$index_file" ]
	then
		if [ -e "$index_file.md5" ]
		then
			local_md5=$(cat "$index_file.md5")
		else
			local_md5=$(md5sum "$index_file" | cut -b-32)
			echo "$local_md5" > "$index_file.md5"
		fi
		echo "Local index file '$index_file' MD5 is $local_md5"
		if [ "${md5:-null}" = "${local_md5:-null}" ]
		then
			echo "Local index file '$index_file' is up-to-date"
		else
			echo "Updating index file '$index_file' (new MD5:$md5)"
			rm "./$index_file"
  			wget -N "$baseurl/$index_file"
			echo "$md5" > "$index_file.md5"
		fi
	else
		echo "Retrieving index file '$index_file'"
  		wget "$baseurl/$index_file"
	fi
done

