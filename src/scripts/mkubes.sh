#!/bin/bash

#server_vars="/mounted/server_vars.json"
#os_vars="/mounted/os_vars.json"
#gwIP=$(jq -r '.[] | select(."name" == "gw") | ."float_ip"' "$server_vars") &&
#nfs_IP=$(jq -r '.[] | select(."name" == "nfs") | ."ip"' "$server_vars") &&
#dr_IP=$(jq -r '.[] | select(."name" == "dr") | ."ip"' "$server_vars") &&
#master_IP=$(jq -r '.[] | select(."name" == "master") | ."ip"' "$server_vars") &&
#node1_IP=$(jq -r '.[] | select(."name" == "node-1") | ."ip"' "$server_vars") &&
#node2_IP=$(jq -r '.[] | select(."name" == "node-2") | ."ip"' "$server_vars") &&
#node3_IP=$(jq -r '.[] | select(."name" == "node-3") | ."ip"' "$server_vars") &&

while getopts "u r h f" opt; do
  case ${opt} in
    u )
      bash /mounted/scripts/update_all_kubernetes_objects.sh
      exit 0
      ;;
    r )
      bash /mounted/scripts/run_kubernetes_jobs.sh
      exit 0
      ;;
    f )
      bash /mounted/scripts/update_conf_files.sh
      exit 0
      ;;
    h )
      echo "| -u to update all kubernetes objects |"
      echo "| -r to run all kubernetes jobs |"
      echo "| -f to update kubernetes configuration files |"
      exit 1
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))