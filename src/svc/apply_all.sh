#!/bin/bash
kubectl apply -f "$HOME"/svc/config.yaml
sleep 1
kubectl apply -f "$HOME"/svc/mariadb/dbconf.yaml
sleep 1
kubectl apply -f "$HOME"/svc/loginsvc/loginsvcconf.yaml
sleep 1
kubectl apply -f "$HOME"/svc/mongo/mongoconf.yaml
sleep 1
kubectl apply -f "$HOME"/svc/postersvc/postconf.yaml
sleep 1
kubectl apply -f "$HOME"/svc/frontend/webconf.yaml
sleep 1
kubectl apply -f "$HOME"/svc/proxy/proxyconf.yaml