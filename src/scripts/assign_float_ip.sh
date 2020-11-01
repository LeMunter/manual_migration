#!/bin/bash
#Login to openstack client
source /keys/am223yd-1dv032-ht20-openrc.sh

floatIp=$(openstack floating ip list -f json | jq -r '.[] | select(."Fixed IP Address" == null) | ."Floating IP Address"' | sed -n 1p)

if test -z "$floatIp"
then
  floatIp=$(openstack floating ip create public -f json | jq '.floating_ip_address')
fi

# Add ip to server_vars.json
# shellcheck disable=SC2046
cat <<< $(jq '.[0].float_ip = "'"$floatIp"'"' /mounted/server_vars.json) > /mounted/server_vars.json

#cat <<< $(jq '.[] | select(."name" == "gw") | ."ip" ='"$ip"'' /mounted/server_vars.json) > /mounted/server_vars2.json