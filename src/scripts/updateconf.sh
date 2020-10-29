#!/bin/bash
kubectl apply -f "$HOME"/mounted/config.yaml
sleep 1
kubectl apply -f "$HOME"/mounted/svc/authdb/dbconf.yaml
sleep 1
kubectl apply -f "$HOME"/mounted/svc/loginsvc/loginsvcconf.yaml
sleep 1
kubectl apply -f "$HOME"/mounted/svc/authdb/mongoconf.yaml
sleep 1
kubectl apply -f "$HOME"/mounted/svc/postersvc/postconf.yaml
sleep 1
kubectl apply -f "$HOME"/mounted/svc/frontend/webconf.yaml