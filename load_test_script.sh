#!/bin/bash
echo "Starting Load Testing"
URLs=("http://foo.localhost" "http://bar.localhost")
for url in "${URLs[@]}";
do
  echo "Testing $url"
  ab -n 1000 -c 100 $url   # ApacheBench is used as an example here. You may need to replace it with your actual load testing tool
done

# Make sure this script is executable (chmod +x load_test_script.sh).