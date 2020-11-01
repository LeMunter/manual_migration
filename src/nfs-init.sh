#!/bin/bash

# Uppdatera alla paket
apt update
apt upgrade -y

# Installera paket som är nödvändiga eller bra att ha
apt-get install -qq apt-transport-https ca-certificates curl software-properties-common jq tmux
apt install nfs-kernel-server
#Create export folders and set permissions
mkdir -p /export/kubedata/mongo
mkdir -p /export/kubedata/maria
chown -R nobody:nogroup /export/kubedata
chmod -R 777 /export/kubedata

#Create exports file
cat <<EOF | sudo tee /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/export/kubedata/maria *(rw,sync,no_root_squash,no_subtree_check)
/export/kubedata/mongo *(rw,sync,no_root_squash,no_subtree_check)
/export/kubedata *(rw,sync,no_root_squash,no_subtree_check)
EOF

exportfs -a
systemctl restart nfs-kernel-server