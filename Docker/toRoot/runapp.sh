#!/bin/bash
set -x
date +" --- RUNNING $(basename $0) %Y-%m-%d_%H:%M:%S --- "

if [ "$IS_LOCAL" = 'true' ]
then
    if [ -z "$KEYCLOAK_ARGUMENTS" ];
    then
        KEYCLOAK_ARGUMENTS="-bprivate=${HOSTNAME}"
    else
        KEYCLOAK_ARGUMENTS="-bprivate=${HOSTNAME} ${KEYCLOAK_ARGUMENTS}"
    fi
else
    PRIVATE_IP=$(curl "169.254.170.2/v2/metadata" | jq -r '.Containers[0].Networks[0]["IPv4Addresses"][0]')

    if [ -z "$KEYCLOAK_ARGUMENTS" ];
    then
        KEYCLOAK_ARGUMENTS="-bprivate=${PRIVATE_IP}"
    else
        KEYCLOAK_ARGUMENTS="-bprivate=${PRIVATE_IP} ${KEYCLOAK_ARGUMENTS}"
    fi
fi

echo "$KEYCLOAK_ARGUMENTS"

exec /home/keycloak/keycloak/bin/standalone.sh --server-config=standalone-ha.xml $KEYCLOAK_ARGUMENTS