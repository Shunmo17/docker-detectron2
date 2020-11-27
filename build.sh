#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
UBUNTU="20.04"
ROS="noetic"
GPU="on"
CUDA="11.0-devel"
LOCAL=false

# Usage
function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    -h,--help              Show the usage."
    echo "    -l,--local             Build with local image instead of downloading from ghcr.io."
    echo "    -g,--gpu <on|off>      Enable GPU support in the Docker."
}

# Get Option
OPTS=`getopt --options g:lh \
         --long gpu:,local,help \
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
    -l|--local)
      LOCAL=true
      shift 1
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

if "${LOCAL}"; then
  echo "------------------------------------------------"
  echo "Build with local image."
  echo "------------------------------------------------"
  IMAGE_SORCE=""
else
  echo "------------------------------------------------"
  echo "Build with remote image downloaded from ghcr.io."
  echo "------------------------------------------------"
  IMAGE_SORCE="ghcr.io/"
fi

export DOCKER_BUILDKIT=1
if [ ${GPU} = "off" ]; then CUDA="none"; fi
echo "------------------------------------------------"
echo "Start to build ${IMAGE_NAME} image"
echo "------------------------------------------------"
if [ ${GPU} = "on" ]; then
  docker build \
    --rm \
    --tag ${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA} \
    --build-arg BASE_IMAGE="${IMAGE_SORCE}shunmo17/ros1.nvidia:${ROS}-cuda${CUDA}" \
    --file Dockerfile .
else
  docker build \
    --rm \
    --tag ${IMAGE_NAME}:${ROS} \
    --build-arg BASE_IMAGE="${IMAGE_SORCE}shunmo17/ros1:${ROS}" \
    --file Dockerfile .
fi
echo "------------------------------------------------"
echo "Finished to build ${IMAGE_NAME} image"
echo "------------------------------------------------"

echo "================================================"
echo " Tagged: ${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA}"
echo "================================================"
echo "UBUNTU : Ubuntu${UBUNTU}"
echo "ROS    : ${ROS}"
echo "GPU    : ${GPU}"
echo "CUDA   : ${CUDA}"
echo "================================================"
