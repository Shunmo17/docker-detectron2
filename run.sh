#!/bin/bash

# Default settings
PROGNAME="$( basename $0 )"
IMAGE_NAME="detectron2"
GPU_NUMBER="0"
CAM_NUMBER="unspecified"
TEST_ENABLE="false"

# Usage
function usage() {
  cat << EOS >&2
Usage:
   ${PROGNAME} [-c, --cam][-g, --gpu]
Options:
  -c, --cam     Disignate rgbd camera number.
                If not disignated, select rgbd camera 0.
  -g, --gpu     Disignate gpu number.
                If not disignated, select gpu 0.
  -h, --help    Show usage.
EOS
  exit 1
}

# Get Option
OPTS=`getopt --options g:c:th \
         --long gpu:,cam:,help \
         --name "$0" -- "$@"`
eval set -- "$OPTS"

while true; do
    case "$1" in
        -g | --gpu )
            GPU_NUMBER=$2;
            shift 2
            ;;
        -c | --cam )
            CAM_NUMBER=$2
            shift 2
            ;;
        -t | --test )
            TEST_ENABLE="true"
            shift 1
            ;;
        -h | --help )
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

echo "===================="
echo "| GPU Number : ${GPU_NUMBER} |"
echo "| Camera Number : ${CAM_NUMBER} |"
echo "===================="

xhost +local:user
NV_GPU=${GPU_NUMBER} \
nvidia-docker run \
    -it --rm \
    --runtime=nvidia \
    --net host \
    --privileged \
    --env DISPLAY=${DISPLAY} \
    --env CAM_NUMBER=${CAM_NUMBER} \
    --env TEST_ENABLE=${TEST_ENABLE} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume ${HOME}/.Xauthority:/root/.Xauthority \
    --volume ${PWD}/common_files/include/alias.sh:/alias.sh \
    --volume ${PWD}/common_files/include/config:/root/.config/terminator/config \
    --volume ${PWD}/common_files/include/ros_setting.sh:/ros_setting.sh \
    --volume ${PWD}/common_files/include/ros_entrypoint.sh:/ros_entrypoint.sh \
    --volume ${PWD}/common_files/include/catkin_build.bash:/catkin_build.bash \
    --volume ${PWD}/../../ros_packages/detectron2_ros:/catkin_ws/src/detectron2 \
    --volume ${PWD}/include/startup.sh:/startup.sh \
    ${IMAGE_NAME}:latest