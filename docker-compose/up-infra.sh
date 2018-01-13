#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
source ./docker-compose.sh
popd > /dev/null

function main () {
    start_service "consul"
    start_service "consul-registrator"
    start_service "traefik"

    mkdir -p ./volume/infra/nexus3/data
    chmod go+w ./volume/infra/nexus3/data
    start_service "nexus3"

    start_service "mysql"
    start_service "rabbitmq"
}

function start_service () {
    docker_compose_in_environment up -d $1
}

main
