#!/usr/bin/env bash
set -euo pipefail
BASEDIR=$(dirname "${BASH_SOURCE}")

### READ AND REPLACE VARS
source <(grep = ${BASEDIR}/florinda.ini | egrep -v '^#' | awk '{ print "export " $1 }')
for _filename in $(find ${BASEDIR}/../ -type f -iname '*.template') ; do
  /usr/bin/envsubst < ${_filename} > $(echo "${_filename%.*}")
done

### DOCKER-COMPOSE COMMAND
docker-compose -f ${BASEDIR}/florinda.yml -p florinda $@
