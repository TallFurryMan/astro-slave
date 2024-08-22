#!/bin/bash

set -eu

owm_weather="https://api.openweathermap.org/data/2.5/weather?lat=48.22&lon=-1.7&units=metric&appid=dd8bd0a1e73a4c9de0196f01dab99960"

json_weather="$(mktemp)"
trap "rm '$json_weather'" EXIT

log() {
	echo "$*" | tee -a .dew.log
}

temperature="$(ssh astromaster tail -1 indi-weather-station/temperatures.db | awk '{print$3}')"
humidity="$(ssh astromaster tail -1 indi-weather-station/humidities.db | awk '{print$3}')"

if [ -n "${temperature:+n}" -a -n "${humidity:+n}" ]
then
	echo "Using local data"
elif timeout 10s curl -s "$owm_weather" > "$json_weather"
then
	echo "Using OpenWeather data"
	temperature="$(jq '.main.temp' "$json_weather")"
	humidity="$(jq '.main.humidity' "$json_weather")"
fi

#dew_point="$(jq '.main.temp-(100-(.main.humidity))/5' "$json_weather")"
#dew_point2="$(jq 'pow(.main.humidity/100;1/8)*(112+0.9*.main.temp)+0.1*.main.temp-112' "$json_weather")"
#dew_point3="$(jq '(0.198+0.0017*.main.temp)*.main.humidity+0.84*.main.temp-19.2' "$json_weather")"
dew_point="$(perl -e "print $temperature-(100-($humidity))/5")"
dew_point2="$(perl -e "print (($humidity/100)**(1.0/8))*(112+0.9*$temperature)+0.1*$temperature-112")"
dew_point3="$(perl -e "print (((0.198+0.0017*$temperature)*$humidity)+(0.84*$temperature)-19.2)")"

if [ -n "${temperature:+n}" -a -n "${humidity:+n}" ]
then
	max_delta="3" # °C

	heater_needed="$(perl -e "print (($temperature < $dew_point3+$max_delta) ? 'yes' : 'no')")"
	d="$(date '+%Y-%m-%d %H:%M:%S.000000')"
	#D="$(date -u -d @$(jq '.dt' "$json_weather") '+%Y-%m-%d %H:%M:%S.000000')"
	D="$d"

	log "$D"
	log "-----------------------------"
	log "Current temperature:    $(perl -e "printf('%.02f°C', ${temperature})")"
	log "Current humidity:       $(perl -e "printf('%.02f%%', ${humidity})")"
	log "-----------------------------"
	log "Approximate dew point:  $(perl -e "printf('%.02f°C', ${dew_point})")"
	log "HGM-approx dew point:   $(perl -e "printf('%.02f°C', ${dew_point2})")"
	log "Sargent dew point:      $(perl -e "printf('%.02f°C', ${dew_point3})")"
	log "-----------------------------"
	log "Delta:                  $(perl -e "printf('%.02f°C', $temperature-($dew_point3))")"
	log "Heater needed:          ${heater_needed}"

	if [ "${1:-}" != "--dry-run" ]
	then
		echo "{\"date\": \"${D}\", \"temperature\": \"${temperature}\", \"humidity\": \"${humidity}\", \"dew_point\": \"${dew_point3}\", \"heater_needed\": \"${heater_needed}\"}" >> ~/.dew_measurements
	 	/bin/echo -e "${D}\t${temperature}\t${humidity}\t${dew_point3}\t${heater_needed}" >> ~/.dew_measurements.db
		rsync .dew_measurements.db astromaster:indi-weather-station/temperatures_dewpoint.db
	fi
else
	echo "Failed downloading current weather ($?)" >&2
fi

if [ -s ~/.dew_measurements ]
then
	if tail -6 ~/.dew_measurements | grep -n '"heater_needed": "yes"'
	then
		echo "Turning/keeping heater ON."
		~/heater_on.sh
	else
		echo "Turning heater OFF."
		~/heater_off.sh
	fi
fi
