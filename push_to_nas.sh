#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
ROS="noetic"
CUDA="11.0-devel"

# NAS Registry Setting
REGISTRY_NAME=mochizushun-nas.synology.me
REGISTRY_PORT=36049

echo "Pushing Image with NVIDIA gpu..."
docker tag ${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA} ${REGISTRY_NAME}:${REGISTRY_PORT}/${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA}
docker push ${REGISTRY_NAME}:${REGISTRY_PORT}/${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA}
