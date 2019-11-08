#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(dirname "${BASH_SOURCE}")
source <(grep = ${BASEDIR}/config.ini | egrep -v '^#' | awk '{ print "export " $1 }')

function capture() {
    fswebcam -q --jpeg 95 --save image_$1.jpeg
    echo -e "[$2] photo | $(date +'%D %T')"
}

function reset_live() {
    count_live=0
    echo -e "[${count_live}] reset | $(date +'%D %T')"
}

function reset_long() {
    count_long=0
    echo -e "[${count_long}] reset | $(date +'%D %T')"
}

function http() {
    bash http.sh $1
}

# Service
#sudo cp florinda_camera.service /etc/systemd/system/
#sudo systemctl daemon-reload
#sudo systemctl restart florinda_camera
#sudo systemctl status florinda_camera
#sudo systemctl enable florinda_camera.service
if [ $# -eq 1 ] ; then
    if [ "$1" == "-s" ] ; then
        for i in $(seq 1 ${INTERVAL_SERV}) ; do
            sleep 1
            echo "[${i}/${INTERVAL_SERV}] Waiting ..."
        done
    fi
fi

count_live=0
count_long=0

http ${HTTP_PORT}
echo -e "[${count_live}] start | $(date +'%D %T')"

while true ; do
	count_live=$((${count_live} + 1))
    count_long=$((${count_long} + 1))

    if [ ${count_live} -eq ${INTERVAL_LIVE} ] ; then
        capture ${INTERVAL_LIVE} ${count_live}
        reset_live
    fi

    if [ ${count_long} -eq ${INTERVAL_LONG} ] ; then
        capture ${INTERVAL_LONG} ${count_long}
        reset_long
    fi

	sleep 1
done

exit 0
