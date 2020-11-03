#!/bin/bash
move_files="$1"

server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"

gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")

if [ "$move_files" == 1 ]; then
  ssh -J $gwIP $master_IP bash svc/apply_all.sh
  echo "test"
fi

bash /mounted/scripts/move_files.sh
ssh -J $gwIP $master_IP bash svc/apply_all.sh