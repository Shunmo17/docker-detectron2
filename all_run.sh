#!/bin/bash

echo "==== Docker Compose ================"
echo "| PC Name : ${HOSTNAME}"
echo "===================================="

# @home
if [ ${HOSTNAME} = "shun-mainpc" ]; then
    echo "==================================="
    echo "|  GPU   | 1 | 1 | 1 | 1 | 1  | 1  |"
    echo "| Camera | 2 | 3 | 6 | 7 | 10 | 11 |"
    echo "==================================="
    docker-compose -f ./docker-compose/shun-mainpc/docker-compose.yml up
fi
# if [ ${HOSTNAME} = "shun-mainpc" ]; then
#     echo "==============================="
#     echo "|  GPU   | 0 | 0 | 1 | 1 | 1 |"
#     echo "| Camera | 0 | 1 | 2 | 3 | 4 |"
#     echo "==============================="
#     docker-compose -f ./docker-compose/shun-mainpc_x6/docker-compose.yml up
# fi

# @07-304
if [ ${HOSTNAME} = "ytpc2020a" ]; then
    echo "======================"
    echo "|  GPU   | 0 | 0 | 1 |"
    echo "| Camera | 0 | 1 | 5 |"
    echo "======================"
    docker-compose -f ./docker-compose/ytpc2020a/docker-compose.yml up
fi
if [ ${HOSTNAME} = "printeps2017a" ]; then
    echo "=========================="
    echo "|  GPU   | 0 | 1 | 1 | 2 |"
    echo "| Camera | 2 | 3 | 4 | 6 |"
    echo "=========================="
    docker-compose -f ./docker-compose/printeps2017a/docker-compose.yml up
fi
if [ ${HOSTNAME} = "printeps2017b" ]; then
    echo "================================"
    echo "|  GPU   | 0 | 0 | 1 | 2  | 2  |"
    echo "| Camera | 7 | 8 | 9 | 10 | 11 |"
    echo "================================"
    docker-compose -f ./docker-compose/printeps2017b/docker-compose.yml up
fi