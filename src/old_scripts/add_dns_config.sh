#!/bin/bash
ip="$1"

ssh ubuntu@"$ip" /bin/bash << HERE
  sudo apt-get update
  sudo apt-get install -y bind9 bind9utils bind9-doc
HERE

bash /mounted/scripts/copy_ns_files.sh "$ip"
