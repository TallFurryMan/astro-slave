#!/bin/bash -eu

to="eric.dejouhanet@gmail.com"
subject="[Obs] Some relays are still on"
body="$(date --rfc-email) - Observatory reports some relays are still on."

if ./relays_query.sh | grep -q '^=R.*0'
then
	printf "To:%s\nSubject:%s\n\n%s\n\n-AstroPanda\n\n" "$to" "$subject" "$body" | msmtp eric.dejouhanet@gmail.com
fi
