#!/bin/bash

# Function to make HTTP request with timestamp logging
make_request() {
    local instance_num=$1
    while true; do
        # Random delay between 5 and 10 seconds
        delay=$((RANDOM % 6 + 5))
        
        # Make request and capture response time
        echo "Instance $instance_num making request..."
        start_time=$(date +%s%N)
        response=$(curl -s http://172.17.0.2:8080)
        end_time=$(date +%s%N)
        
        # Calculate elapsed time in milliseconds
        elapsed=$((($end_time - $start_time)/1000000))
        
        # Print response and timing information
        echo "Instance $instance_num: $response (${elapsed}ms)"
        
        sleep $delay
    done
}

echo "Starting load test with 10 concurrent instances..."

# Launch 10 concurrent requests
for i in {1..10}; do
    make_request $i &
done

# Wait for all background processes
wait
