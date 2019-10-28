#!/bin/bash
######################################################
# Script:  mosquitto_receiver.sh
# Author:  Pedro Pavan
# Date:    22/Dec/2017
# Purpose: IOT - just4fun
######################################################

#------------------------------------------------------------------
#README
#------------------------------------------------------------------

#------------------------------------------------------------------
# INSTALL MOSQUITTO
#sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
#sudo apt-get update
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

#------------------------------------------------------------------
# INSTALL mp3gain (normalizer)
#wget http://ftp.br.debian.org/debian/pool/main/m/mp3gain/mp3gain_1.5.2-r2-2+deb7u1_amd64.deb
#sudo gdebi mp3gain_1.5.2-r2-2+deb7u1_amd64.deb
#sudo apt-get -f install
#------------------------------------------------------------------

# Main
TOPIC="$(hostname)/audio"
SERVER="$(hostname -I | tr ' ' '\n' | head -1 | tr -d '[:space:]')"
MSG_COUNT=0
LOG_FILE="./log/mosquitto_$(date +%s).log"

clear
echo -e "Listening on ${SERVER} (${TOPIC})" | tee -a ${LOG_FILE}

while read msg
do
	if [ -n "${msg}" ]; then
		MSG_COUNT=$(expr ${MSG_COUNT} + 1)

		case "${msg}" in
			"mp3_"*)
				_mp3_file=./data/$(echo ${msg} | sed 's/mp3_//g')
				
				if [ -f ${_mp3_file}.mp3 ]; then
					echo "[$(date '+%D %T')|${MSG_COUNT}] Play: ${_mp3_file}.mp3" | tee -a ${LOG_FILE}
					mpg123 ${_mp3_file}.mp3 > /dev/null 2>&1
				else
					echo "[$(date '+%D %T')|${MSG_COUNT}] ERROR: file not found > ${_mp3_file}.mp3" | tee -a ${LOG_FILE}
				fi
			;;

			*)
				echo "[$(date '+%D %T')|${MSG_COUNT}] Speak: ${msg}" | tee -a ${LOG_FILE}
				echo "${msg}" | festival --tts
		esac
	fi
done < <(mosquitto_sub -h ${SERVER} -t "${TOPIC}")

exit 0
