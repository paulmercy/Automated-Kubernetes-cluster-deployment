#!/bin/bash

# Number of request
NUM_REQUESTS=1000

# Function to generate load for a specific host
function generate_load() {
    local host=$1
    local service_name=$2

    echo "Generating load for $host..."
    failed_requests=0
    start_time=$(date +%s)
    for ((i=0; i<$NUM_REQUESTS; i++))
    do
        # Generate random paths for HTTP requests (e.g., /random-path-123)
        random_path="/random-path-$((RANDOM % 1000))"
        response=$(curl -s -o /dev/null -w "%{http_code} %{time_total}\n" "http://$host$random_path")
        http_code=$(echo "$response" | awk '{print $1}')
        time_total=$(echo "$response" | awk '{print $2}')
        if [ "$http_code" != "200" ]; then
            ((failed_requests++))
        fi
        echo "$time_total" >> "${service_name}_load_test_results.txt"
    done
    end_time=$(date +%s)
    total_duration=$((end_time - start_time))
    reqs_per_second=$(awk "BEGIN {printf \"%.2f\", $NUM_REQUESTS / $total_duration}")

    echo "Load test for $host completed. Results are saved in ${service_name}_load_test_results.txt"

    # Calculate load testing statistics
    avg_duration=$(awk '{ sum += $1 } END { printf "%.3f", sum/NR }' "${service_name}_load_test_results.txt")
    sorted_durations=$(sort -n "${service_name}_load_test_results.txt")
    p90_index=$((NUM_REQUESTS * 90 / 100))
    p95_index=$((NUM_REQUESTS * 95 / 100))
    p90_duration=$(sed -n "${p90_index}p" <<< "$sorted_durations")
    p95_duration=$(sed -n "${p95_index}p" <<< "$sorted_durations")

    # Post the results as a comment on the GitHub Pull Request using GitHub Actions environment variables
    comment="Load Testing Results for $service_name:
    - Average HTTP request duration: $avg_duration seconds
    - 90th percentile HTTP request duration: $p90_duration seconds
    - 95th percentile HTTP request duration: $p95_duration seconds
    - Percentage of failed HTTP requests: $((failed_requests * 100 / NUM_REQUESTS)) %
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