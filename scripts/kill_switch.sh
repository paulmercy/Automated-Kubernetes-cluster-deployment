#!/bin/bash

read -p "Are you sure you want to proceed with deleting all services and pods in all namespaces? (y/N): " confirm

if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
  echo "Deleting all services in all namespaces..."
  kubectl delete svc --all -A

  echo "Deleting all pods in all namespaces..."
  kubectl delete pods --all -A

  echo "Kill switch executed successfully!"
else
  echo "Kill switch aborted."
fi
