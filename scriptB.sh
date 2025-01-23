#!/bin/bash
make_request() {
    local instance_num=$1
    while true; do
        delay=$((RANDOM % 6 + 5))

        echo "Instance $instance_num making request..."
        start_time=$(date +%s%N)
        response=$(curl -s http://127.0.0.1)
        end_time=$(date +%s%N)

        elapsed=$((($end_time - $start_time)/1000000))

        echo "Instance $instance_num: $response (${elapsed}ms)"

        sleep $delay
    done
}
echo "Starting load test with 10 concurrent instances..."
for i in {1..10}; do
    make_request $i &
done
wait
