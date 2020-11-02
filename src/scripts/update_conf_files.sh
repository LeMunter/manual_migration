#!/bin/bash
server_vars="/mounted/server_vars.json"

dr=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars")
nfs=$(jq -r '.[] | select(."name" == "nfs") | ."ip"' "$server_vars")

#Update mariadb config
cat <<< $(sudo cat /mounted/svc/mariadb/dbconf.yaml | yq w -d0 - spec.nfs.server $nfs) > /mounted/svc/mariadb/dbconf.yaml
cat <<< $(sudo cat /mounted/svc/mariadb/dbconf.yaml | yq w -d2 - spec.template.spec.containers[0].image "$dr":5000/mariadb) > /mounted/svc/mariadb/dbconf.yaml

#Update postersvc config
cat <<< $(sudo cat /mounted/svc/mariadb/dbconf.yaml | yq w -d0 - spec.template.spec.containers[0].image "$dr":5000/postsvc) > /mounted/svc/postersvc/postconf.yaml