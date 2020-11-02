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


join_command=$(ssh -J "$gwIP" "$master_IP" sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tail -2)
echo "$join_command">/mounted/kub_join

ssh -J "$gwIP" "$master_IP" /bin/bash << HERE
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  curl https://docs.projectcalico.org/manifests/calico.yaml -O
  kubectl apply -f calico.yaml
HERE

ssh -J "$gwIP" "$node1_IP" sudo kubeadm join 172.16.0.6:6443 --token 6lcrij.ei4m41lmdarlhp5c \
    --discovery-token-ca-cert-hash sha256:c0d26237f24a14ad668b0254d45b0ee7146965ad692454160fb93f370927a463

ssh -J "$gwIP" "$node2_IP" sudo kubeadm join 172.16.0.6:6443 --token 6lcrij.ei4m41lmdarlhp5c \
    --discovery-token-ca-cert-hash sha256:c0d26237f24a14ad668b0254d45b0ee7146965ad692454160fb93f370927a463

ssh -J "$gwIP" "$node3_IP" sudo kubeadm join 172.16.0.6:6443 --token 6lcrij.ei4m41lmdarlhp5c \
    --discovery-token-ca-cert-hash sha256:c0d26237f24a14ad668b0254d45b0ee7146965ad692454160fb93f370927a463

