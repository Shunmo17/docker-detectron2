#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
UBUNTU="20.04"
ROS="noetic"
GPU="on"
CUDA="11.0-devel"

# Usage
function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    -h,--help              Display the usage and exit."
    echo "    -g,--gpu <on|off>      Enable GPU support in the Docker."
}

# Get Option
OPTS=`getopt --options g:h \
         --long gpu:,help \
         --name "$0" -- "$@"`
eval set -- "$OPTS"

while true; do
  case $1 in
    -g|--gpu)
      GPU="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      if [ ! -z $2 ];
      then
        echo "Invalid parameter: $2"
        exit 1
      fi
      break
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
done

export DOCKER_BUILDKIT=1
if [ ${GPU} = "off" ]; then CUDA="none"; fi
echo "------------------------------------------------"
echo "Start to build ${IMAGE_NAME} image"
echo "------------------------------------------------"
if [ ${GPU} = "on" ]; then
  docker build \
    --rm \
    --tag ${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA} \
    --build-arg BASE_IMAGE="ghcr.io/shunmo17/ubuntu.nvidia:${UBUNTU}-cuda${CUDA}" \
    --build-arg ROS_DISTRO=${ROS} \
    --file Dockerfile .
else
  docker build \
    --rm \
    --tag ${IMAGE_NAME}:${ROS} \
    --build-arg BASE_IMAGE="ghcr.io/shunmo17/ubuntu:${UBUNTU}" \
    --build-arg ROS_DISTRO=${ROS} \
    --file Dockerfile .
fi
echo "------------------------------------------------"
echo "Finished to build ${IMAGE_NAME} image"
echo "------------------------------------------------"

echo "================================================"
echo " ${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA}"
echo "================================================"
echo "UBUNTU : Ubuntu${UBUNTU}"
echo "ROS    : ${ROS}"
echo "GPU    : ${GPU}"
echo "CUDA   : ${CUDA}"
echo "================================================"
