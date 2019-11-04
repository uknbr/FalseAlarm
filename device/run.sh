#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(dirname "${BASH_SOURCE}")

source <(grep = ${BASEDIR}/config.ini | egrep -v '^#' | awk '{ print "export " $1 }')
count=0

measure_all="n"
measure_volts="n"
measure_temp="n"
measure_uptime="n"
measure_memory="n"
measure_cpu="n"

SERVER="$(hostname -I | tr ' ' '\n' | head -1 | tr -d '[:space:]')"

function usage() {
    exit $1
}

if [ $# -eq 0 ] ; then
    usage 1
fi

while getopts :htvumc opt
do
    case $opt in
        v)
            measure_volts="y"
            ;;
        t)
            measure_temp="y"
            ;;
        u)
            measure_uptime="y"
            ;;
        m)
            measure_memory="y"
            ;;        
        c)
            measure_cpu="y"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 2
            ;;
    esac
done


while true ; do
	count=$((${count} + 1))

	if [ "${measure_temp}" == "y" ] ; then
        _temp=$(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')
        echo -e "[${count} | temp | $(date +'%D %T')] ${_temp}"
        mosquitto_pub -h ${SERVER} -t $(hostname)/${TEMP_TOPIC} -m ${_temp}
	fi

	if [ "${measure_volts}" == "y" ] ; then
        _volts=$(vcgencmd measure_volts | egrep -o '[0-9]*\.[0-9]*')
		echo -e "[${count} | volt | $(date +'%D %T')] ${_volts}"
		mosquitto_pub -h ${SERVER} -t $(hostname)/${VOLTS_TOPIC} -m ${_volts}
	fi

    if [ "${measure_uptime}" == "y" ] ; then
        _uptime=$(/usr/bin/uptime -p | sed 's/up //g')
        echo -e "[${count} | up   | $(date +'%D %T')] ${_uptime}"
        mosquitto_pub -h ${SERVER} -t $(hostname)/${UPTIME_TOPIC} -m "${_uptime}"
    fi

    if [ "${measure_memory}" == "y" ] ; then
        _mem=$(/usr/bin/free | /bin/grep Mem | /usr/bin/awk '{print $3/$2 * 100.0}')
        echo -e "[${count} | mem  | $(date +'%D %T')] ${_mem}"
        mosquitto_pub -h ${SERVER} -t $(hostname)/${MEMORY_TOPIC} -m "${_mem}"
    fi

    if [ "${measure_cpu}" == "y" ] ; then
        _cpu=$(/usr/bin/top -bn1 | /bin/grep "Cpu(s)" | /bin/sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | /usr/bin/awk '{print 100 - $1}')
        echo -e "[${count} | cpu  | $(date +'%D %T')] ${_cpu}"
        mosquitto_pub -h ${SERVER} -t $(hostname)/${CPU_TOPIC} -m "${_cpu}"
    fi

	sleep ${INTERVAL}
done

exit 0
