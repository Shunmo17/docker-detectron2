#!/bin/bash

# Default settings
PROGNAME="$( basename $0 )"
IMAGE_NAME="detectron2"
GPU_NUMBER="0"
CAM_NUMBER="unspecified"
TEST_ENABLE="false"

# HSR, MANUAL, or PC
ROS_MASTER_MODE="PC"

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

echo "================================="
echo "| GPU Number : ${GPU_NUMBER}"
echo "| Camera Number : ${CAM_NUMBER}"
echo "================================="
# --gpus device=${GPU_NUMBER} \
xhost +local:user
docker run \
    -it --rm \
    --net host \
    --gpus all \
    --env DISPLAY=${DISPLAY} \
    --env QT_X11_NO_MITSHM=1 \
    --env ROS_MASTER_MODE=${ROS_MASTER_MODE} \
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
    --volume ${PWD}/../../ros_packages/ytlab_environment/detectron2_ros_msgs:/catkin_ws/src/detectron2_ros_msgs \
    --volume ${PWD}/include/detectron2_ros:/catkin_ws/src/detectron2_ros \
    --volume ${PWD}/include/startup.sh:/startup.sh \
    ${IMAGE_NAME}:latest
    