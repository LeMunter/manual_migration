#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

#create float ip
ip=$(openstack floating ip create public -f json | jq '.floating_ip_address')

# Add ip to server_vars.json
# shellcheck disable=SC2046 disable=SC2094
cat <<< $(jq '.[0].float_ip ='"$ip"'' /mounted/server_vars.json) > /mounted/server_vars.json