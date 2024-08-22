#!/bin/bash

echo "Etat du cabanon: $(wget -qO- http://cabanon.quenottes.dejouha.net:4242/ || echo "pas de réponse")." >&2
wget -qO- http://cabanon.quenottes.dejouha.net:4242/abort || exit 1
echo "Aborting..." >&2
while [ "$(wget -qO- http://cabanon.quenottes.dejouha.net:4242/ | jq -r .state)" != "4" ]
do
	echo "Waiting for aborted..."
	sleep 10
done
