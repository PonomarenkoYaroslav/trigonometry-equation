#!/bin/bash

docker rm -f srv1 srv2 srv3 2>/dev/null
declare -A busy_count idle_count

IMAGE_NAME="yaroslavpon/http-server:latest"
BUSY_THRESHOLD=70
IDLE_THRESHOLD=10
CHECK_INTERVAL=30  # Seconds

# Function to check CPU usage
check_cpu_usage() {
    local container_name=$1
    local cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" $container_name | sed 's/%//' || echo 0)
    echo ${cpu_usage%%.*}
}

# Function to determine if a container is busy
is_container_busy() {
    local container_name=$1
    local cpu_usage=$(check_cpu_usage $container_name)
    [[ ! -z "$cpu_usage" && "$cpu_usage" -ge $BUSY_THRESHOLD ]]
}

# Function to determine if a container is idle
is_container_idle() {
    local container_name=$1
    local cpu_usage=$(check_cpu_usage $container_name)
    [[ ! -z "$cpu_usage" && "$cpu_usage" -le $IDLE_THRESHOLD ]]
}

# Function to stop and remove a container gracefully
stop_container_gracefully() {
    local container_name=$1

    # Send SIGTERM signal to the container
    docker kill --signal=SIGTERM $container_name

    # Wait for the container to stop naturally
    sleep 5
    docker stop $container_name

    # Remove the container
    docker rm $container_name
}


# Function to update containers while ensuring zero downtime
update_containers() {
    local new_image_id=$(docker pull $IMAGE_NAME | grep 'Digest' | awk '{print $2}')

    for container in srv1 srv2 srv3; do
        if docker ps | grep -q "$container"; then
            if [[ "$container" == "srv1" ]]; then
                if ! docker ps | grep -q "srv2"; then
                    docker run -d --name srv2 --cpuset-cpus 1 -p 8081:80 $IMAGE_NAME
                fi
            elif [[ "$container" == "srv2" ]]; then
                if ! docker ps | grep -q "srv1"; then
                    docker run -d --name srv1 --cpuset-cpus 0 -p 8080:80 $IMAGE_NAME
                fi
            elif [[ "$container" == "srv3" ]]; then
                if ! docker ps | grep -q "srv2"; then
                    docker run -d --name srv2 --cpuset-cpus 1 -p 8081:80 $IMAGE_NAME
                fi
            fi

            docker stop $container
            docker rm $container
            docker run -d --name $container --cpuset-cpus ${container:3:1} -p 808${container:3:1}:80 $IMAGE_NAME
        fi
    done
}

# Start the first container
if ! docker ps | grep -q "srv1"; then
    docker run -d --name srv1 --cpuset-cpus 0 -p 8080:80 $IMAGE_NAME
fi

# Main monitoring loop
while true; do
    if is_container_busy "srv1"; then
        busy_count["srv1"]=$((busy_count["srv1"] + 1))
        idle_count["srv1"]=0

        if [ ${busy_count["srv1"]} -ge 2 ] && ! docker ps | grep -q "srv2"; then
            docker run -d --name srv2 --cpuset-cpus 1 -p 8081:80 $IMAGE_NAME
        fi
    else
        idle_count["srv1"]=$((idle_count["srv1"] + 1))
        busy_count["srv1"]=0
    fi

    if docker ps | grep -q "srv2"; then
        if is_container_busy "srv2"; then
            busy_count["srv2"]=$((busy_count["srv2"] + 1))
            idle_count["srv2"]=0

            if [ ${busy_count["srv2"]} -ge 2 ] && ! docker ps | grep -q "srv3"; then
                docker run -d --name srv3 --cpuset-cpus 2 -p 8082:80 $IMAGE_NAME
            fi
        elif is_container_idle "srv2" && ! docker ps | grep -q "srv3"; then
            idle_count["srv2"]=$((idle_count["srv2"] + 1))
            busy_count["srv2"]=0

            if [ ${idle_count["srv2"]} -ge 2 ]; then
                stop_container_gracefully "srv2"
            fi
        else
            idle_count["srv2"]=0
        fi
    fi

    if docker ps | grep -q "srv3"; then
        if is_container_idle "srv3"; then
            idle_count["srv3"]=$((idle_count["srv3"] + 1))
            busy_count["srv3"]=0

            if [ ${idle_count["srv3"]} -ge 2 ]; then
                stop_container_gracefully "srv3"
            fi
        else
            idle_count["srv3"]=0
        fi
    fi

    # Perform periodic update checks
    if (( $(date +%s) % 300 == 0 )); then
        update_containers
    fi

    sleep $CHECK_INTERVAL
done

