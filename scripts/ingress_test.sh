#!/bin/bash

# Define the cluster name
CLUSTER_NAME="kind-multi-node"

# Create a Kubernetes cluster with kind
kind create cluster --config=kind-config.yaml --name $CLUSTER_NAME

# Apply Ingress Controller using a specific version (update this URL if needed)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml

# Wait for Ingress-nginx to get started
echo "Waiting for Ingress-nginx to get started..."
sleep 60

# Create http-echo deployments and services (assuming you have this defined in deployments.yaml)
kubectl apply -f bar-deployments.yaml
kubectl apply -f foo-deployments.yaml

# Apply Ingress rules (using the updated ingress.yaml)
kubectl apply -f ingress.yaml

# Check Ingress rules
kubectl get ingress

# Ensure the ingress and deployments are healthy before proceeding to the next step (you can add some checks here)

# Additional information
echo "Cluster and Ingress setup completed successfully."
