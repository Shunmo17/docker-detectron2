#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"
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

# build unique image
docker build \
    --rm \
    --no-cache=${CACHE} \
    --tag ${IMAGE_NAME}:latest \
    --file Dockerfile .