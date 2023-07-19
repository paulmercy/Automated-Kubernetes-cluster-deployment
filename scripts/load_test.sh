#!/bin/bash

# Install hey
# go get -u github.com/rakyll/hey

# # Run load test
# hey -n 1000 -c 100 http://bar.localhost > foo_results.txt
# hey -n 1000 -c 100 http://foo.localhost > bar_results.txt

# # Post the output of the load testing result as a comment on the GitHub Pull Request
# gh pr comment ${GH_PR_NUMBER} --body "$(cat foo_results.txt)"
# gh pr comment ${GH_PR_NUMBER} --body "$(cat bar_results.txt)"




# Number of requests to generate
# NUM_REQUESTS=1000

# # Get the cluster IP
# CLUSTER_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# # Function to generate load for a specific host
# function generate_load() {
#     local host=$1
#     local service_name=$2

#     echo "Generating load for $host..."
#     ab -n $NUM_REQUESTS -c 10 http://$host/ > "${service_name}_load_test_results.txt"
#     echo "Load test for $host completed. Results are saved in ${service_name}_load_test_results.txt"

#     # Extract relevant load testing statistics
#     avg_duration=$(awk '/Time taken for tests/ {print $5}' "${service_name}_load_test_results.txt")
#     p90_duration=$(awk '/90% / {print $2}' "${service_name}_load_test_results.txt")
#     p95_duration=$(awk '/95% / {print $2}' "${service_name}_load_test_results.txt")
#     failed_requests=$(awk '/Failed requests/ {print $3}' "${service_name}_load_test_results.txt")
#     reqs_per_second=$(awk '/Requests per second/ {print $4}' "${service_name}_load_test_results.txt")

#     # Post the results as a comment on the GitHub Pull Request using GitHub Actions environment variables
#     comment="Load Testing Results for $service_name:
#     - Average HTTP request duration: $avg_duration ms
#     - 90th percentile HTTP request duration: $p90_duration ms
#     - 95th percentile HTTP request duration: $p95_duration ms
#     - Percentage of failed HTTP requests: $failed_requests %
#     - Requests per second handled: $reqs_per_second"

#     echo "$comment" > "load_test_results.txt"
#     echo "::set-output name=load_test_results::load_test_results.txt"
# }

# # Main script execution
# echo "Starting load test..."

# # Use the cluster IP to replace 'your-cluster-ip'
# FOO_HOST="foo.localhost.$CLUSTER_IP.nip.io"
# BAR_HOST="bar.localhost.$CLUSTER_IP.nip.io"

# # Capture logs of deployments during load testing
# kubectl logs -n default -l app=http-echo -c http-echo --follow > "deployments_logs.txt" &
# LOGS_PID=$!

# # Generate load for 'foo' and 'bar' hosts
# generate_load "$FOO_HOST" "foo"
# generate_load "$BAR_HOST" "bar"

# # Stop capturing logs
# kill $LOGS_PID

# echo "Load testing completed. All results are saved."



# Install Fortio Operator
kubectl create -f https://raw.githubusercontent.com/verfio/fortio-operator/master/deploy/fortio.yaml

# Verify that the Fortio Operator is running
kubectl get pods

# Deploy Fortio Server
kubectl apply -f https://raw.githubusercontent.com/verfio/fortio-operator/master/deploy/crds/fortio_v1alpha1_server_cr.yaml

# Verify that the service is up
kubectl get service fortio-server

# Create LoadTest
cat <<EOF | kubectl apply -f -
apiVersion: fortio.verf.io/v1alpha1
kind: LoadTest
metadata:
  name: foo-loadtest
spec:
  duration: 10s
  url: "http://foo.localhost"
  action: load
---
apiVersion: fortio.verf.io/v1alpha1
kind: LoadTest
metadata:
  name: bar-loadtest
spec:
  duration: 10s
  url: "http://bar.localhost"
  action: load
EOF

# Verify that the Job to run the LoadTest is created and the Pod has successfully completed the required task
kubectl get jobs
kubectl get pods
