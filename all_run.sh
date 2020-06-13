#!/bin/bash

# get pc name
PC_NAME=`hostname`

echo "==== Docker Compose ================"
echo "| PC Name : ${PC_NAME}"
echo "===================================="

# @home
if [ ${PC_NAME} = "shun-mainpc" ]; then
    echo "==============================="
    echo "|  GPU   | 0 | 0 | 1 | 1 | 1 |"
    echo "| Camera | 0 | 1 | 6 | 8 | 9 |"
    echo "==============================="
    docker-compose -f ./docker-compose/docker-compose_shun-mainpc.yml up
fi

# @07-304
if [ ${PC_NAME} = "ytpc2020a" ]; then
    echo "=================================="
    echo "|  GPU   | 0 | 0 | 1 | 1 | 2 | 2 |"
    echo "| Camera | 0 | 1 | 2 | 3 | 4 | 5 |"
    echo "=================================="
    docker-compose -f ./docker-compose/docker-compose_ytpc2020a.yml up
fi
if [ ${PC_NAME} = "dlbox" ]; then
    echo "===================================="
    echo "|  GPU   | 0 | 0 | 1 | 1 | 2  | 2  |"
    echo "| Camera | 6 | 7 | 8 | 9 | 10 | 11 |"
    echo "===================================="
    docker-compose -f ./docker-compose/docker-compose_dlbox.yml up
fi
