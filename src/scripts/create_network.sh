#!/bin/bash

source /keys/am223yd-1dv032-ht20-openrc.sh
server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"
network_name="kub_network"
sub_network_name="kub_subnetwork"
gatewayIP="172.16.10.1"
router_name="pub_router"

openstack network create $network_name --availability-zone-hint nova
cat <<<$(jq '.network ="'"$network_name"'"' $os_vars) > $os_vars

openstack subnet create $sub_network_name --network $network_name --allocation-pool start=172.16.10.2,end=172.16.10.120 --gateway $gatewayIP --subnet-range 172.16.10.0/24 --dns-nameserver 8.8.8.8 --dns-nameserver 8.8.4.4
cat <<<$(jq '.sub_network ="'"$sub_network_name"'"' $os_vars) > $os_vars
#
openstack router create $router_name --availability-zone-hint nova
openstack router set $router_name --external-gateway public
openstack router add subnet $router_name $sub_network_name
cat <<<$(jq '.router ="'"$router_name"'"' $os_vars) > $os_vars


sg1="SSH"
sg2="HTTP2"
openstack security group create $sg1
openstack security group rule create $sg1 --protocol tcp --dst-port 22

openstack security group create $sg2
openstack security group rule create $sg2 --protocol tcp --dst-port 80
cat <<< $(jq '.sg[0] = "'"$sg1"'"' "$os_vars") > "$os_vars"
cat <<< $(jq '.sg[1] = "'"$sg2"'"' "$os_vars") > "$os_vars"

floatIp1=$(openstack floating ip create public -f json | jq -r '.floating_ip_address')
floatIp2=$(openstack floating ip create public -f json | jq -r '.floating_ip_address')
cat <<< $(jq '.float_ips[0] = "'"$floatIp1"'"' "$os_vars") > "$os_vars"
cat <<< $(jq '.float_ips[1] = "'"$floatIp2"'"' "$os_vars") > "$os_vars"


export GATEWAY_FLOATING_IP=$floatIp2
#i=$(jq ".float_ips | length" $os_vars)
#jq ".float_ips[$i]" $os_vars

