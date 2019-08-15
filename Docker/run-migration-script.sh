#!/usr/bin/env bash
# backup original file
cp toRoot/standalone-ha.xml standalone-ha-bk.xml

docker build -t capra/keycloak .
docker run --name keycloak-migration -it -d capra/keycloak bash

#runs the migration script inside the container
docker exec -it keycloak-migration sh -c 'cd /home/keycloak/keycloak/bin/; ./jboss-cli.sh --file=migrate-standalone-ha.cli'

# copy out file from container
docker cp keycloak-migration:/home/keycloak/keycloak/standalone/configuration/standalone-ha.xml standalone-ha-migrated.xml

# Remove container when we're done
docker rm -f -v keycloak-migration