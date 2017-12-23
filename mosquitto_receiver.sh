#!/bin/bash
######################################################
# Script:  mosquitto_receiver.sh
# Author:  Pedro Pavan
# Date:    22/Dec/2017
# Purpose: IOT - just4fun
######################################################

#------------------------------------------------------------------
# INSTALL MOSQUITTO
#sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
#ssudo apt-get update
#sudo apt-get install mosquitto mosquitto-clients
#sudo service mosquitto status
#------------------------------------------------------------------

#------------------------------------------------------------------
# DOWNLOAD & INSTALL MQTTFX (local)
#wget http://www.jensd.de/apps/mqttfx/1.5.0/mqttfx-1.5.0-64bit.deb
#sudo gdebi mqttfx-*s-64bit.deb 
#------------------------------------------------------------------

#------------------------------------------------------------------
# TESTING
#mosquitto_sub -h localhost -t $(hostname) -v
#mosquitto_pub -h localhost -t $(hostname) -m "testing"
#------------------------------------------------------------------

#------------------------------------------------------------------
# INSTALL FESTIVAL (speaker)
#sudo apt-get install festival
#echo "welcome to my world!" | festival --tts
#------------------------------------------------------------------

#------------------------------------------------------------------
# INSTALL MPG123 (player)
#sudo apt-get install mpg123
#------------------------------------------------------------------

# Main
TOPIC="$(hostname)/audio"
SERVER="$(hostname -I | tr ' ' '\n' | head -1 | tr -d '[:space:]')"
MSG_COUNT=0

clear
echo -e "Listening on ${SERVER} (${TOPIC})"

while read msg
do
	if [ -n "${msg}" ]; then
		MSG_COUNT=$(expr ${MSG_COUNT} + 1)

		case "${msg}" in
			"mp3_"*)
				_mp3_file=$(echo ${msg} | sed 's/mp3_//g')
				
				if [ -f mp3/${_mp3_file}.mp3 ]; then
					echo "[$(date '+%D %T')|${MSG_COUNT}] Play: ${_mp3_file}.mp3"
					mpg123 mp3/${_mp3_file}.mp3 > /dev/null 2>&1
				fi
			;;

			*)
				echo "[$(date '+%D %T')|${MSG_COUNT}] Speak: ${msg}"
				echo "${msg}" | festival --tts
		esac
	fi
done < <(mosquitto_sub -h ${SERVER} -t "${TOPIC}")

exit 0
