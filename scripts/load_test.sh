#!/bin/bash

# Number of requests
NUM_REQUESTS=1000

# Function to generate load for a specific host
function generate_load() {
    local host=\$1
    local service_name=\$2
    local failed_requests=0
    local start_time=$(date +%s)

    echo "Generating load for $host..."
    for ((i=0; i<$NUM_REQUESTS; i++))
    do
        # Generate random paths for HTTP requests (e.g., /random-path-123)
        random_path="/random-path-$((RANDOM % 1000))"
        http_status=$(curl -s -o /dev/null -w "%{http_code}\n%{time_total}\n" "http://$host$random_path" >> "${service_name}_durations.txt")
        if ((http_status >= 400 && http_status <= 599)); then
            ((failed_requests++))
        fi
    done
    local end_time=$(date +%s)

    echo "Load test for $host completed. Results are saved in ${service_name}_load_test_results.txt"

    # Calculate load testing statistics
    local total_time=$((end_time - start_time))
    local reqs_per_second=$(awk -v total=$NUM_REQUESTS -v time=$total_time 'BEGIN { printf "%.2f", total/time }')
    local failed_requests_percentage=$(awk -v failed=$failed_requests -v total=$NUM_REQUESTS 'BEGIN { printf "%.2f", (failed/total)*100 }')

    local avg_duration=$(awk '{ sum += \$1 } END { printf "%.3f", sum/NR }' "${service_name}_durations.txt")
    local sorted_durations=$(sort -n "${service_name}_durations.txt")
    local actual_num_requests=$(wc -l < "${service_name}_durations.txt")
    local p90_index=$((actual_num_requests * 90 / 100))
    local p95_index=$((actual_num_requests * 95 / 100))
    local p90_duration=$(sed -n "${p90_index}p" "${service_name}_durations.txt")
    local p95_duration=$(sed -n "${p95_index}p" "${service_name}_durations.txt")

    # Post the results as a comment on the GitHub Pull Request using GitHub Actions environment variables
    local comment="Load Testing Results for $service_name:
    - Average HTTP request duration: $avg_duration seconds
    - 90th percentile HTTP request duration: $p90_duration seconds
    - 95th percentile HTTP request duration: $p95_duration seconds
    - Percentage of failed HTTP requests: $failed_requests_percentage %
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