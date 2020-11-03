#!/bin/bash

source /keys/am223yd-1dv032-ht20-openrc.sh &&
bash /mounted/scripts/create_network.sh &&
bash /mounted/scripts/create_all_servers.sh &&

#Kubernetes
#Init and join for master and nodes
bash /mounted/scripts/initialize_kub.sh &&
#Update all kube configs and move files to master
bash /mounted/scripts/update_conf_files.sh &&

bash /mounted/scripts/move_files.sh &&
bash /mounted/scripts/build_all_images.sh &&
bash /mounted/scripts/udate_all_kubernetes_objects.sh 1

proxy_port=$(ssh -J $gwIP $master_IP kubectl get svc proxysvc -o json | jq '.spec.ports[].nodePort')
echo "Completed!"
echo "Load balancer IP: $GATEWAY_FLOATING_IP"
echo "Proxy-Service Port: $proxy_port"