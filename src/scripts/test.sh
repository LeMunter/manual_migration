cat <<EOF | sudo tee /test/exports
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

cat <<EOF | sudo tee /test/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF