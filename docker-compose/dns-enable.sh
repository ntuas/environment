#!/usr/bin/env bash
set -e
pushd . > /dev/null
cd $(dirname ${BASH_SOURCE[0]})
source ./docker-compose.sh
source ./ips.sh
source ./env.sh
popd > /dev/null

function dns_enable () {
    start_service "dns"
    add_as_dns_to_host_dnsmasq ${DOMAIN_NAME} "dns" 53

#    start_service "consul"
#    add_as_dns_to_host_dnsmasq ${CONSUL_DOMAIN_NAME} "consul" 8600
#
#    start_service "traefik"
#    add_as_address_to_host_dnsmasq ${PUBLIC_DOMAIN_NAME} "traefik"
}

function start_service () {
    docker_compose_in_environment up -d $1
}

function add_as_dns_to_host_dnsmasq () {
    domain_name=$1
    dns_ip=$(ip_of_service $2 1)
    dns_port=$3
    sudo sh -c "echo \"server=/${domain_name}/${dns_ip}#${dns_port}\" > /etc/NetworkManager/dnsmasq.d/docker_${PROJECT_NAME}_${domain_name//./-}_server.conf"
    sudo systemctl restart NetworkManager
}

function add_as_address_to_host_dnsmasq () {
    domain_name=$1
    public_lb_ip=$(ip_of_service $2 1)
    sudo sh -c "echo \"address=/${domain_name}/${public_lb_ip}\" > /etc/NetworkManager/dnsmasq.d/docker_${PROJECT_NAME}_${domain_name//./-}_address.conf"
    sudo systemctl restart NetworkManager
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    dns_enable
fi

