#!/bin/bash
server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars") &&
nfs_IP=$(jq -r '.[] | select(."name" == "nfs") | ."ip"' "$server_vars") &&
dr_IP=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars") &&
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars") &&
node1_IP=$(jq -r '.[] | select(."name" == "node-1") | ."ip"' "$server_vars") &&
node2_IP=$(jq -r '.[] | select(."name" == "node-2") | ."ip"' "$server_vars") &&
node3_IP=$(jq -r '.[] | select(."name" == "node-3") | ."ip"' "$server_vars") &&

proxy_port=$(ssh -J $gwIP $master_IP kubectl get svc proxysvc -o json | jq '.spec.ports[].nodePort')
echo "Completed!"
echo "Load balancer IP: $GATEWAY_FLOATING_IP"
echo "Proxy-Service Port: $proxy_port"


#sudo cat /mounted/svc/experiment/exconf.yaml | yq w -d0 - spec.template.spec.containers[0].image "$dr":5000/exp
