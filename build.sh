#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
UBUNTU="18"
ROS_DISTRO="melodic"
CUDA_VERSION="10.0"
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

if [ ${ROS_DISTRO} = "kinetic" ]; then UBUNTU="16"; fi
if [ ${ROS_DISTRO} = "melodic" ]; then UBUNTU="18"; fi
if [ ${ROS_DISTRO} = "noetic" ]; then UBUNTU="20"; fi
if [ ${GPU} = "off" ]; then CUDA="off"; fi

if [ ${UPDATE} = "true" ]; then
  echo "[SKIP] building ubuntu base image and building ros base image"
fi
if [ ${UPDATE} = "false" ]; then
  # build ubuntu base image
  DOCKERFILE="${PWD}/common_files/Dockerfiles/ubuntu/Dockerfile"
  if [ ${CUDA} = "off" ]; then
    docker build \
      --rm \
      --tag shunmo_base_image:ubuntu${UBUNTU}_gpu-off_cuda-${CUDA} \
      --build-arg BASE_IMAGE="ubuntu:${UBUNTU}.04" \
      --build-arg UBUNTU=${UBUNTU} \
      --file ${DOCKERFILE} .
  else
    docker build \
      --rm \
      --tag shunmo_base_image:ubuntu${UBUNTU}_gpu-off_cuda-${CUDA} \
      --build-arg BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU}.04" \
      --build-arg UBUNTU=${UBUNTU} \
      --file ${DOCKERFILE} .
  fi

  # for using nvidia gpu
  DOCKERFILE="${PWD}/common_files/Dockerfiles/nvidia-gpu/Dockerfile"
  if [ ${GPU} = "on" ]; then
    docker build \
      --rm \
      --tag shunmo_base_image:ubuntu${UBUNTU}_gpu-on_cuda-${CUDA} \
      --build-arg BASE_IMAGE="shunmo_base_image:ubuntu${UBUNTU}_gpu-off_cuda-${CUDA}" \
      --file ${DOCKERFILE} .
  fi

  # build ros base image
  DOCKERFILE="${PWD}/common_files/Dockerfiles/ros1/Dockerfile"
  docker build \
      --rm \
      --tag shunmo_base_image:ros1-${ROS_DISTRO}_gpu-${GPU}_cuda-${CUDA} \
      --build-arg BASE_IMAGE="shunmo_base_image:ubuntu${UBUNTU}_gpu-${GPU}_cuda-${CUDA}" \
      --build-arg ROS_DISTRO=${ROS_DISTRO} \
      --file ${DOCKERFILE} .
fi

# build unique image
docker build \
  --rm \
  --no-cache=${CACHE} \
  --tag ${IMAGE_NAME}:ros1-${ROS_DISTRO}_gpu-${GPU}_cuda-${CUDA} \
  --build-arg BASE_IMAGE="shunmo_base_image:ros1-${ROS_DISTRO}_gpu-${GPU}_cuda-${CUDA}" \
  --build-arg ROS_DISTRO=${ROS_DISTRO} \
  --file Dockerfile .

echo "================================"
echo "UBUNTU version : Ubuntu${UBUNTU}.04"
echo "ROS version : ${ROS_DISTRO}"
echo "GPU support : ${GPU}"
echo "CUDA support : ${CUDA}"
echo "================================"