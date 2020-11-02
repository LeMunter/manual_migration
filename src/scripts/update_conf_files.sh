#!/bin/bash

source /keys/am223yd-1dv032-ht20-openrc.sh
server_vars="/mounted/server_vars.json"

dr=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars")
nfs=$(jq -r '.[] | select(."name" == "nfs") | ."ip"' "$server_vars")
floatIp=$(jq -r '.[] | select(."name" == "proxy") | ."float_ip"' "$server_vars")

#Update mariadb config
cat <<< $(sudo cat /mounted/svc/mariadb/dbconf.yaml | yq w -d0 - spec.nfs.server $nfs) > /mounted/svc/mariadb/dbconf.yaml
cat <<< $(sudo cat /mounted/svc/mariadb/dbconf.yaml | yq w -d2 - spec.template.spec.containers[0].image "$dr":5000/mariadb) > /mounted/svc/mariadb/dbconf.yaml

#Update mongodb config
cat <<< $(sudo cat /mounted/svc/mongo/mongoconf.yaml | yq w -d0 - spec.nfs.server $nfs) > /mounted/svc/mongo/mongoconf.yaml

#Update postersvc config
cat <<< $(sudo cat /mounted/svc/postersvc/postconf.yaml | yq w -d0 - spec.template.spec.containers[0].image "$dr":5000/postsvc) > /mounted/svc/postersvc/postconf.yaml

#Update loginsvc config
cat <<< $(sudo cat /mounted/svc/loginsvc/loginsvcconf.yaml | yq w -d0 - spec.template.spec.containers[0].image "$dr":5000/loginsvc) > /mounted/svc/loginsvc/loginsvcconf.yaml

#Update websvc config
cat <<< $(sudo cat /mounted/svc/frontend/webconf.yaml | yq w -d0 - spec.template.spec.containers[0].image "$dr":5000/websvc) > /mounted/svc/frontend/webconf.yaml

cat <<< $(sudo cat /mounted/svc/config.yaml | yq w -d0 - data.FRONTEND_SERVER_ADDR "$floatIp") > /mounted/svc/config.yaml
