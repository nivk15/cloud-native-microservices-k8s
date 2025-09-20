#!/bin/bash

#kind create cluster --config kind-config.yaml

#kubectl apply -f ./multi-service-app/namespace.yaml

# docker build -t stocks-app -f multi-service-app/stocks/Dockerfile multi-service-app/
# docker build -t capgains-app -f multi-service-app/capital-gains/Dockerfile multi-service-app/
#  
# kind load docker-image stocks-app
# kind load docker-image capgains-app

kubectl apply -f multi-service-app/capital-gains/deployment.yaml
kubectl apply -f multi-service-app/capital-gains/service.yaml
kubectl apply -f multi-service-app/stocks/service.yaml
kubectl apply -f multi-service-app/stocks/secret.yaml
kubectl apply -f multi-service-app/stocks/deployment.yaml
kubectl apply -f multi-service-app/nginx/service.yaml
kubectl apply -f multi-service-app/nginx/configmap.yaml
kubectl apply -f multi-service-app/nginx/deployment.yaml
kubectl apply -f multi-service-app/database/persistentVolume.yaml
kubectl apply -f multi-service-app/database/persistentVolumeClaim.yaml
kubectl apply -f multi-service-app/database/deployment.yaml
kubectl apply -f multi-service-app/database/service.yaml
