#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
ROS="noetic"
CUDA="11.0-devel"
SOURCE="ghcr.io"

# NAS Registry Setting
REGISTRY_NAME=mochizushun-nas.synology.me
REGISTRY_PORT=36049

# Usage
function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "    -n,--nas              Pull image from nas. (Need to login beforehand.)"
    echo "    -g,--github           Pull image from ghcr.io. (Need to login beforehand.)"
    echo "    -h,--help             Show the usage."
}

# Get Option
OPTS=`getopt --options ngh \
         --long nas,github,help \
         --name "$0" -- "$@"`
eval set -- "$OPTS"

while true; do
  case $1 in
    -n|--nas)
      SOURCE=${REGISTRY_NAME}:${REGISTRY_PORT}
      shift 1
      ;;
    -g|--github)
      SOURCE="ghcr.io/shunmo17"
      shift 1
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

echo "Downloading Image with NVIDIA gpu..."
docker pull ${SOURCE}/${IMAGE_NAME}.nvidia:${ROS}-cuda${CUDA}
