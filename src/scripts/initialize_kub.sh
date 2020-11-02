#!/bin/bash

server_vars="/mounted/server_vars.json"
gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")
node1_IP=$(jq -r '.[] | select(."name" == "node-1") | ."ip"' "$server_vars")
node2_IP=$(jq -r '.[] | select(."name" == "node-2") | ."ip"' "$server_vars")
node3_IP=$(jq -r '.[] | select(."name" == "node-3") | ."ip"' "$server_vars")

#Init kube network on master and save join key to "kub_join" file
join_command=$(ssh -J "$gwIP" "$master_IP" sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tail -2)
echo "$join_command">/mounted/kub_join

#copy config file and create calico service
ssh -J "$gwIP" "$master_IP" /bin/bash << HERE
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  curl https://docs.projectcalico.org/manifests/calico.yaml -O
  kubectl apply -f calico.yaml
HERE

#Join nodes to network
ssh -J "$gwIP" "$node1_IP" eval sudo "$join_command"

ssh -J "$gwIP" "$node2_IP" eval sudo "$join_command"

ssh -J "$gwIP" "$node3_IP" eval sudo "$join_command"
