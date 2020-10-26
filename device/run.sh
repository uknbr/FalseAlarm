#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(dirname "${BASH_SOURCE}")
source <(grep = ${BASEDIR}/config.ini | egrep -v '^#' | awk '{ print "export " $1 }')

SERVER="$(hostname -I | tr ' ' '\n' | head -1 | tr -d '[:space:]')"
count=0
run_service="n"
measure_all="n"
measure_volts="n"
measure_temp="n"
measure_uptime="n"
measure_memory="n"
measure_cpu="n"
measure_disk="n"
measure_net="n"

function usage() {
    exit $1
}

if [ $# -eq 0 ] ; then
    usage 1
fi

while getopts :htvumcdns opt
do
    case $opt in
        s)
            run_service="y"
            ;;
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
        d)
            measure_disk="y"
            ;;
        c)
            measure_cpu="y"
            ;;
        n)
            measure_net="y"
            ;;
        h)
            usage 0
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            usage 2
            ;;
    esac
done

# Service
#sudo cp florinda_device.service /etc/systemd/system/
#sudo systemctl daemon-reload
#sudo systemctl restart florinda_device
#sudo systemctl status florinda_device
#sudo systemctl enable florinda_device.service
if [ "${run_service}" == "y" ] ; then
    for i in $(seq 1 ${INTERVAL}) ; do
        sleep 1
        echo "[${i}/${INTERVAL}] Waiting ..."
    done
fi

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

    if [ "${measure_disk}" == "y" ] ; then
        _disk=$(/bin/df -hl | /usr/bin/awk '/root/ { print $5 }' | tr -d '%')
        echo -e "[${count} | disk | $(date +'%D %T')] ${_disk}"
        mosquitto_pub -h ${SERVER} -t $(hostname)/${DISK_TOPIC} -m "${_disk}"
    fi

    if [ "${measure_net}" == "y" ] ; then
        _speed=$(which speedtest)
        if [ -n ${_speed} ] ; then
            _speed_file=$(mktemp)
            ${_speed} > ${_speed_file}

            _download=$(grep 'Download:' ${_speed_file} | awk '{ print $2 }')
            _upload=$(grep 'Upload:' ${_speed_file} | awk '{ print $2 }')

            echo -e "[${count} | down | $(date +'%D %T')] ${_download}"
            echo -e "[${count} | load | $(date +'%D %T')] ${_upload}"

            mosquitto_pub -h ${SERVER} -t $(hostname)/${NET_DL_TOPIC} -m "${_download}"
            mosquitto_pub -h ${SERVER} -t $(hostname)/${NET_UL_TOPIC} -m "${_upload}"

            rm -f ${_speed_file}
        fi
    fi

	sleep ${INTERVAL}
done

exit 0
