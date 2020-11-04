#!/bin/bash

server_vars="/mounted/server_vars.json"
os_vars="/mounted/os_vars.json"

gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars")
master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars")

jobs=$(ssh -J $gwIP $master_IP kubectl get job exp -o json | jq -r '.metadata.name')

if [ ! -z "$jobs" ]; then
    ssh -J $gwIP $master_IP kubectl delete job $jobs
fi

bash /mounted/scripts/move_files.sh
ssh -J $gwIP $master_IP bash svc/apply_jobs.sh
#pods=$(ssh -J $gwIP $master_IP kubectl get pods --selector=job-name=exp --output=jsonpath='{.items[*].metadata.name}')
#ssh -J $gwIP $master_IP kubectl logs -f "$pods"