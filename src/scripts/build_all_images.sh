#!/bin/bash
server_vars="/mounted/server_vars.json"

hostIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
remoteIP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")
dr=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars")

mariadb=$(sudo cat /mounted/svc/mariadb/dbconf.yaml | yq r -d2 - spec.template.spec.containers[0].image)
poster=$(sudo cat /mounted/svc/postersvc/postconf.yaml | yq r -d0 - spec.template.spec.containers[0].image)
login=$(sudo cat /mounted/svc/loginsvc/loginsvcconf.yaml | yq r -d0 - spec.template.spec.containers[0].image)
websvc=$(sudo cat /mounted/svc/frontend/webconf.yaml | yq r -d0 - spec.template.spec.containers[0].image)
exp=$(sudo cat /mounted/svc/experiment/exconf.yaml | yq r -d0 - spec.template.spec.containers[0].image)

ssh -J "$hostIP" "$remoteIP" /bin/bash << HERE
    sudo docker build "$HOME"/svc/mariadb --tag $mariadb
    sudo docker push $mariadb
    sudo docker build "$HOME"/svc/postersvc --tag $poster
    sudo docker push $poster
    sudo docker build "$HOME"/svc/loginsvc --tag $login
    sudo docker push $login
    sudo docker build "$HOME"/svc/frontend --tag $websvc
    sudo docker push $websvc
    sudo docker build "$HOME"/svc/experiment --tag $exp
    sudo docker push $exp
HERE
