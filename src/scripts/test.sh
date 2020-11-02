#!/bin/bash

#bash /mounted/scripts/test2.sh "$server_vars"

server_vars="/mounted/server_vars.json"
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
nfs_IP=$(jq -r '.[] | select(."name" == "nfs") | ."ip"' "$server_vars")
dr_IP=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars")
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")
node1_IP=$(jq -r '.[] | select(."name" == "node-1") | ."ip"' "$server_vars")
node2_IP=$(jq -r '.[] | select(."name" == "node-2") | ."ip"' "$server_vars")
node3_IP=$(jq -r '.[] | select(."name" == "node-3") | ."ip"' "$server_vars")


ssh-copy-id -i ~/.ssh/id_rsa ubuntu@$gwIP
