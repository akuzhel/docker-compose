#!/usr/bin/env bash

NETWORK_DATA="network.json"
HOST='dev.gazelle.nl'
HOST_SUFFIX='-docker-auto'
BRIDGE_NETWORK_ID=`docker network ls|grep 'pon-tier'|awk ' {print $1}'`

docker network inspect ${BRIDGE_NETWORK_ID} > $NETWORK_DATA
#echo php write-hosts.php -i ${NETWORK_DATA} -h ${HOST} -s ${HOST_SUFFIX} ####
#exit  ##########
CONFIG_FILE=`php write-hosts.php -i $NETWORK_DATA -h $HOST -s $HOST_SUFFIX |xargs`

if [[ -n ${CONFIG_FILE} ]]; then
    SOURCE=`pwd`/${CONFIG_FILE}
    echo Generated file '"'${SOURCE}'"';
    TARGET=/etc/dnsmasq.d/"$CONFIG_FILE"

    if [[ -f ${TARGET} ]]; then
        sudo rm -f $TARGET
        echo Removed previous config '"'${TARGET}'"'
    fi

    sudo cp  ${SOURCE} ${TARGET} && \
    sudo service dnsmasq restart
fi

