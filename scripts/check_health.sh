#!/bin/bash

# Check if the Ingress controller is ready
function check_ingress_controller() {
    echo "Checking Ingress controller status..."
    kubectl wait pods -n ingress-nginx --for condition=Ready --timeout=180s
    if [ $? -eq 0 ]; then
        echo "Ingress controller is ready."
    else
        echo "Ingress controller is not ready. Exiting..."
        exit 1
    fi
}

# Check if the deployments are ready
function check_deployments() {
    local deployments=("foo-deployment" "bar-deployment") # Add other deployment names here if needed

    echo "Checking deployments status..."
    for deployment in "${deployments[@]}"; do
        kubectl rollout status deployment/${deployment} -n default --timeout=180s
        if [ $? -eq 0 ]; then
            echo "Deployment ${deployment} is ready."
        else
            echo "Deployment ${deployment} is not ready. Exiting..."
            exit 1
        fi
    done
}

# Main script execution
check_ingress_controller
check_deployments

echo "All resources are healthy. Proceeding to the next step..."
