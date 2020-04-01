#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
UBUNTU="18"
ROS="melodic"
GPU="on"
CUDA="on"
CACHE="false"

# Build Setting
UPDATE="false"

# Usage
function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    -h,--help              Display the usage and exit."
    echo "    -u,--update            Build only unique image."
    echo "    -n,--no_cache          Build without cache."
}

# Get Option
OPTS=`getopt --options hun \
         --long help,update \
         --name "$0" -- "$@"`
eval set -- "$OPTS"

while true; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -u|--update)
      UPDATE="true"
      shift 1
      ;;
    -n|--no_cache)
      CACHE="true" 
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

if [ ${UPDATE} = "true" ]; then
  echo "[SKIP] building ubuntu base image and building ros base image"
fi
if [ ${UPDATE} = "false" ]; then
    # build ubuntu base image
    DOCKERFILE="${PWD}/common_files/Dockerfiles/ubuntu${UBUNTU}_gpu-${GPU}_cuda-${CUDA}/Dockerfile"
    docker build \
        --rm \
        --tag shunmo_base_image:ubuntu${UBUNTU}_gpu-${GPU}_cuda-${CUDA} \
        --file ${DOCKERFILE} .

    # build ros base image
    DOCKERFILE="${PWD}/common_files/Dockerfiles/${ROS}/Dockerfile"
    docker build \
        --rm \
        --tag shunmo_base_image:ros-${ROS}_gpu-${GPU}_cuda-${CUDA} \
        --build-arg BASE_IMAGE="shunmo_base_image:ubuntu${UBUNTU}_gpu-${GPU}_cuda-${CUDA}" \
        --file ${DOCKERFILE} .
fi

# build unique image
docker build \
    --rm \
    --no-cache=${CACHE} \
    --tag ${IMAGE_NAME}:base \
    --build-arg BASE_IMAGE="shunmo_base_image:ros-${ROS}_gpu-${GPU}_cuda-${CUDA}" \
    --file Dockerfile .

echo "================================"
echo -e "UBUNTU version : Ubuntu${UBUNTU}.04"
echo -e "ROS version : ${ROS}"
echo -e "GPU support : ${GPU}"
echo -e "CUDA support : ${CUDA}"
echo "================================"