#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(dirname "${BASH_SOURCE}")

source <(grep = ${BASEDIR}/config.ini | egrep -v '^#' | awk '{ print "export " $1 }')
count=0

measure_all="n"
measure_volts="n"
measure_temp="n"

while getopts :hatv opt
do
    case $opt in
        v)
            measure_volts="y"
            ;;
        t)
            measure_temp="y"
            ;;            
        a)
            measure_all="y"
            ;;        
        h)
            usage
            exit 1
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
		echo -ne "[${count} | temp | $(date +'%D %T')] "
		vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*'
	fi

	if [ "${measure_volts}" == "y" ] ; then
		echo -ne "[${count} | volt | $(date +'%D %T')] "
		vcgencmd measure_volts | egrep -o '[0-9]*\.[0-9]*'
	fi

	sleep ${INTERVAL}
done

exit 0
