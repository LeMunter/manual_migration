#!/bin/bash
server_vars="/mounted/server_vars.json"

#bash /mounted/scripts/create_gw.sh "$server_vars" &&
#bash /mounted/scripts/create_nfs.sh "$server_vars" &&
#bash /mounted/scripts/create_registry.sh "$server_vars" &&
#bash /mounted/scripts/create_master.sh "$server_vars" &&
#bash /mounted/scripts/create_nodes.sh "$server_vars"

gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
nfs_IP=$(jq -r '.[] | select(."name" == "nfs") | ."ip"' "$server_vars")
dr_IP=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars")
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")
node1_IP=$(jq -r '.[] | select(."name" == "node-1") | ."ip"' "$server_vars")
node2_IP=$(jq -r '.[] | select(."name" == "node-2") | ."ip"' "$server_vars")
node3_IP=$(jq -r '.[] | select(."name" == "node-3") | ."ip"' "$server_vars")

#Check that all init scripts are done
ssh "$gwIP" cloud-init status -w
#ssh -J "$gwIP" "$nfs_IP" cloud-init status -w
#ssh -J "$gwIP" "$dr_IP" cloud-init status -w
ssh -J "$gwIP" "$master_IP" cloud-init status -w
ssh -J "$gwIP" "$node1_IP" cloud-init status -w
ssh -J "$gwIP" "$node2_IP" cloud-init status -w
ssh -J "$gwIP" "$node3_IP" cloud-init status -w

#Move daemon file for docker on master and nodes
bash /mounted/scripts/move_docker_daemon.sh "$gwIP" "$master_IP"
bash /mounted/scripts/move_docker_daemon.sh "$gwIP" "$node1_IP"
bash /mounted/scripts/move_docker_daemon.sh "$gwIP" "$node2_IP"
bash /mounted/scripts/move_docker_daemon.sh "$gwIP" "$node3_IP"

#Init and join for master and nodes
bash /mounted/scripts/initialize_kub.sh
