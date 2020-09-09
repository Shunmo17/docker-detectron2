#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
UBUNTU="18"
ROS="melodic"
GPU="on"
CUDA="10.0"

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

if [ ${ROS} = "kinetic" ]; then UBUNTU="16"; fi
if [ ${ROS} = "melodic" ]; then UBUNTU="18"; fi
if [ ${ROS} = "noetic" ]; then UBUNTU="20"; fi
if [ ${GPU} = "off" ]; then CUDA="none"; fi

# build ubuntu base image
echo "------------------------------------------------"
echo "Start to build ubuntu${UBUNTU} base image"
echo "------------------------------------------------"
DOCKERFILE="${PWD}/common_files/Dockerfiles/ubuntu/Dockerfile"
if [ ${CUDA} = "none" ]; then
  docker build \
    --rm \
    --tag shunmo_base:ubuntu${UBUNTU}_gpu-off_cuda-${CUDA} \
    --build-arg BASE_IMAGE="ubuntu:${UBUNTU}.04" \
    --build-arg UBUNTU=${UBUNTU} \
    --file ${DOCKERFILE} .
else
  docker build \
    --rm \
    --tag shunmo_base:ubuntu${UBUNTU}_gpu-off_cuda-${CUDA} \
    --build-arg BASE_IMAGE="nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}.04" \
    --build-arg UBUNTU=${UBUNTU} \
    --file ${DOCKERFILE} .
fi
echo "------------------------------------------------"
echo "Finished to build ubuntu${UBUNTU} base image"
echo "------------------------------------------------"

# for using nvidia gpu
if [ ${GPU} = "on" ]; then
  echo "------------------------------------------------"
  echo "Start to build image for using nvidia gpu"
  echo "------------------------------------------------"
  DOCKERFILE="${PWD}/common_files/Dockerfiles/nvidia-gpu/Dockerfile"
  docker build \
    --rm \
    --tag shunmo_base:ubuntu${UBUNTU}_gpu-on_cuda-${CUDA} \
    --build-arg BASE_IMAGE="shunmo_base:ubuntu${UBUNTU}_gpu-off_cuda-${CUDA}" \
    --file ${DOCKERFILE} .
  echo "------------------------------------------------"
  echo "Finished to build image for using nvidia gpu"
  echo "------------------------------------------------"
fi

# build ros base image
echo "------------------------------------------------"
echo "Start to build ros ${ROS} image"
echo "------------------------------------------------"
DOCKERFILE="${PWD}/common_files/Dockerfiles/ros1/Dockerfile"
docker build \
    --rm \
    --tag shunmo_base:ros1-${ROS}_gpu-${GPU}_cuda-${CUDA} \
    --build-arg BASE_IMAGE="shunmo_base:ubuntu${UBUNTU}_gpu-${GPU}_cuda-${CUDA}" \
    --build-arg ROS_DISTRO=${ROS} \
    --file ${DOCKERFILE} .
  echo "------------------------------------------------"
echo "Finished to build ros image"
echo "------------------------------------------------"

echo "------------------------------------------------"
echo "Start to build ${IMAGE_NAME} image"
echo "------------------------------------------------"
# build unique image
docker build \
  --rm \
  --tag ${IMAGE_NAME}:ros1-${ROS}_gpu-${GPU}_cuda-${CUDA} \
  --build-arg BASE_IMAGE="shunmo_base:ros1-${ROS}_gpu-${GPU}_cuda-${CUDA}" \
  --build-arg ROS_DISTRO=${ROS} \
  --file Dockerfile .
echo "------------------------------------------------"
echo "Finished to build ${IMAGE_NAME} image"
echo "------------------------------------------------"

echo "================================================"
echo " ${IMAGE_NAME}"
echo "================================================"
echo "UBUNTU : UBUNTU${UBUNTU}.04"
echo "ROS : ${ROS}"
echo "GPU : ${GPU}"
echo "CUDA : ${CUDA}"
echo "================================================"