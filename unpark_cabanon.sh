#!/bin/bash

# ./accessory_on.sh
count=0
while ! state="$(timeout 2 wget -qO- http://cabanon.quenottes.dejouha.net:4242/)"
do
	sleep 5
	count=$(($count+1))
	if [ $count -eq 10 ]
	then
		echo "$(date) - No answer"
		exit 1
	else
		printf "%s" .
	fi
done
echo "$(date) - Etat du cabanon: $state." >&2
wget -qO- http://cabanon.quenottes.dejouha.net:4242/open || exit 1
echo "$(date) - Unparking..." >&2
count=0
while [ "$(wget -qO- http://cabanon.quenottes.dejouha.net:4242/ | jq -r .state)" != "3" ]
do
	echo "$(date) - Waiting for opened..."
	sleep 20
	count=$(($count+1))
	if [ $count -eq 200 ]
	then
		echo "$(date) - Too long, aborting." >&2
		./abort_cabanon.sh
		exit 1
	fi
done
