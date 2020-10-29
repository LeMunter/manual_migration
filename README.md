   
    multipass launch --name <name>   
    multipass mount C:/Users/anton/"OneDrive - student.lnu.se"/Kurser/1dv032/exam-3/src/ anton:/mounted/

####Install multipass vm

    sudo apt-get update && sudo apt upgrade -y
    sudo apt-get install -y net-tools
    sudo apt install -y python3-pip python3-dev
    sudo pip3 install --upgrade pip
    sudo pip3 install python-openstackclient
    sudo apt-get install -qq apt-transport-https ca-certificates curl software-properties-common jq
      
    source /keys/am223yd-1dv032-ht20-openrc.sh
      -Enter password
       
    # Add key to vm
    cp /keys/secrets/test.pem ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
    # Copy key to cloud gateway
    scp ~/.ssh/id_rsa ubuntu@194.47.177.127:
       
####gateway
    sudo apt-get install tmux
    ssh -i id_rsa ubuntu@172.16.0.8
    cp id_rsa ~/.ssh/id_rsa
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
    
####Install node master
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config  
    curl https://docs.projectcalico.org/manifests/calico.yaml -O
    kubectl apply -f calico.yaml
    
####Docker registry
    sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
    
    
####Storage
    sudo apt install -y nfs-kernel-server
####Ska köras på alla noder
    sudo apt install -y nfs-common
    kubeadm join 172.16.0.8:6443 --token zs6lq7.05d5zwoj6s4tb1z0 \
           --discovery-token-ca-cert-hash sha256:34906c82d0a7ffb37443b46ad440e33065491a49a16f1dfd04022447e7438364
    