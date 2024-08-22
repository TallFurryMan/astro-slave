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

started="$(date)"
echo "$(date) - Etat du cabanon: $(wget -qO- http://cabanon.quenottes.dejouha.net:4242/ || echo "pas de réponse" )." >&2
wget -qO- http://cabanon.quenottes.dejouha.net:4242/close || exit 1
echo "$(date) - Parking..." >&2
count=0
while [ "$(wget -qO- http://cabanon.quenottes.dejouha.net:4242/ | jq -r .state)" != "0" ]
do
	echo "$(date) - Waiting for closed..."
	sleep 20
	count=$(($count+1))
	if [ $count -eq 200 ]
	then
		echo "$(date) - Too long, aborting." >&2
		./abort_cabanon.sh
		exit 1
	fi
done
echo "$(date) - Was started on $started"
# ./accessory_off.sh
