#!/usr/bin/env bash

# Read variables
source ../.env

# Dump network data
BRIDGE_NETWORK_NAME=`docker network ls|grep "${NETWORK_NAME}"|awk ' {print $2}'`
docker network inspect ${BRIDGE_NETWORK_NAME} > ${NETWORK_INFO_DUMP}
echo 'Dumped network data for "'${BRIDGE_NETWORK_NAME}'"'

# Prepare dnsmasq configuration file in PHP script
CONFIG_FILE=`php write-hosts.php -i ${NETWORK_INFO_DUMP} -h $HOST -p ${CONTAINER_PREFIX} -s ${CONF_FILE_SUFFIX} |xargs`

# Put dnsmasq configuration file inplace and restart service
if [[ -n ${CONFIG_FILE} ]]; then
    SOURCE=`pwd`/${CONFIG_FILE}
    echo Generated file '"'${SOURCE}'"';
    TARGET=/etc/dnsmasq.d/"$CONFIG_FILE"

    if [[ -f ${TARGET} ]]; then
        sudo rm -f ${TARGET}
        echo Removed previous config '"'${TARGET}'"'
    fi

    sudo cp  ${SOURCE} ${TARGET} && \
    sudo service dnsmasq restart
    echo DNS service:
    sudo service dnsmasq status

    rm ${NETWORK_INFO_DUMP}
fi

