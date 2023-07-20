#!/bin/bash

# Install hey
# go get -u github.com/rakyll/hey

# # Run load test
# hey -n 1000 -c 100 http://bar.localhost > foo_results.txt
# hey -n 1000 -c 100 http://foo.localhost > bar_results.txt

# # Post the output of the load testing result as a comment on the GitHub Pull Request
# gh pr comment ${GH_PR_NUMBER} --body "$(cat foo_results.txt)"
# gh pr comment ${GH_PR_NUMBER} --body "$(cat bar_results.txt)"



NUM_REQUESTS=1000

# Function to generate load for a specific host
function generate_load() {
    local host=$1
    local service_name=$2

    echo "Generating load for $host..."
    for ((i=0; i<$NUM_REQUESTS; i++))
    do
        # Generate random paths for HTTP requests (e.g., /random-path-123)
        random_path="/random-path-$((RANDOM % 1000))"
        curl -s -o /dev/null -w "%{time_total}\n" "http://$host$random_path" >> "${service_name}_load_test_results.txt"
    done

    echo "Load test for $host completed. Results are saved in ${service_name}_load_test_results.txt"

    # Calculate load testing statistics
    avg_duration=$(awk '{ sum += $1 } END { printf "%.3f", sum/NR }' "${service_name}_load_test_results.txt")
    sorted_durations=$(sort -n "${service_name}_load_test_results.txt")
    p90_index=$((NUM_REQUESTS * 90 / 100))
    p95_index=$((NUM_REQUESTS * 95 / 100))
    p90_duration=$(sed -n "${p90_index}p" <<< "$sorted_durations")
    p95_duration=$(sed -n "${p95_index}p" <<< "$sorted_durations")
    failed_requests=$(awk '/Failed requests/ {print $3}' "${service_name}_load_test_results.txt")
    reqs_per_second=$(awk '/Requests per second/ {print $4}' "${service_name}_load_test_results.txt")

    # Post the results as a comment on the GitHub Pull Request using GitHub Actions environment variables
    comment="Load Testing Results for $service_name:
    - Average HTTP request duration: $avg_duration seconds
    - 90th percentile HTTP request duration: $p90_duration seconds
    - 95th percentile HTTP request duration: $p95_duration seconds"
    - Percentage of failed HTTP requests: $failed_requests %
    - Requests per second handled: $reqs_per_second"

    echo "$comment" > "load_test_results.txt"
    echo "$comment" | tee "load_test_results.txt"
    # echo "$comment" | gh issue comment ${{ github.event.issue.number }} --body -


    # Post the comment using GitHub Actions environment variable
    echo "::add-comment::$comment"
}

# Main script execution
echo "Starting load test..."

# Use the cluster IP to replace 'your-cluster-ip'
CLUSTER_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
FOO_HOST="foo.localhost.$CLUSTER_IP.nip.io"
BAR_HOST="bar.localhost.$CLUSTER_IP.nip.io"

# Capture logs of deployments during load testing
kubectl logs -n default -l app=http-echo -c http-echo --follow > "deployments_logs.txt" &
LOGS_PID=$!

# Generate load for 'foo' and 'bar' hosts
generate_load "$FOO_HOST" "foo"
generate_load "$BAR_HOST" "bar"

# Stop capturing logs
kill $LOGS_PID

echo "Load testing completed. All results are saved."