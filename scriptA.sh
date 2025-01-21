#!/bin/bash

docker rm -f srv1 srv2 srv3 2>/dev/null

declare -A busy_count idle_count

check_cpu_usage() {
    local container_name=$1
    local cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" $container_name | sed 's/%//' || echo 0)
    echo ${cpu_usage%%.*}
}

is_container_busy() {
    local container_name=$1
    local threshold=70
    local cpu_usage=$(check_cpu_usage $container_name)

    if [[ -z "$cpu_usage" || "$cpu_usage" -eq 0 ]]; then
        return 1
    fi

    if (( cpu_usage > threshold )); then
        return 0
    else
        return 1
    fi
}

if ! docker ps | grep -q "srv1"; then
    docker run -d --name srv1 --cpuset-cpus 0 -p 8080:80 yaroslavpon/http-server:latest
fi

while true; do
    if is_container_busy "srv1"; then
        busy_count["srv1"]=$((busy_count["srv1"] + 1))
        idle_count["srv1"]=0
        if [ ${busy_count["srv1"]} -ge 2 ]; then
            if ! docker ps | grep -q "srv2"; then
                docker run -d --name srv2 --cpuset-cpus 1 -p 8081:80 yaroslavpon/http-server:latest
            fi
        fi
    else
        idle_count["srv1"]=$((idle_count["srv1"] + 1))
        busy_count["srv1"]=0
    fi

    if docker ps | grep -q "srv2"; then
        if is_container_busy "srv2"; then
            busy_count["srv2"]=$((busy_count["srv2"] + 1))
            idle_count["srv2"]=0
            if [ ${busy_count["srv2"]} -ge 2 ]; then
                if ! docker ps | grep -q "srv3"; then
                    docker run -d --name srv3 --cpuset-cpus 2 -p 8082:80 yaroslavpon/http-server:latest
                fi
            fi
        else
            idle_count["srv2"]=$((idle_count["srv2"] + 1))
            busy_count["srv2"]=0
            if [ ${idle_count["srv2"]} -ge 2 ]; then
                docker stop srv2
                docker rm srv2
            fi
        fi
    fi

    if docker ps | grep -q "srv3"; then
        if ! is_container_busy "srv3"; then
            idle_count["srv3"]=$((idle_count["srv3"] + 1))
            if [ ${idle_count["srv3"]} -ge 2 ]; then
                docker stop srv3
                docker rm srv3
            fi
        else
            idle_count["srv3"]=0
        fi
    fi

    sleep 30
done

