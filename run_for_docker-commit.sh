#!/bin/bash

# Default settings
IMAGE_NAME="detectron2"

xhost +local:user
docker run \
    -it --rm \
    --net host \
    --privileged \
    --runtime=nvidia \
    --env DISPLAY=${DISPLAY} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume ${HOME}/.Xauthority:/root/.Xauthority \
    --volume ${PWD}/common_files/include/alias.sh:/alias.sh \
    --volume ${PWD}/common_files/include/config:/root/.config/terminator/config \
    --volume ${PWD}/common_files/include/ros_setting.sh:/ros_setting.sh \
    --volume ${PWD}/common_files/include/ros_entrypoint.sh:/ros_entrypoint.sh \
    --volume ${PWD}/common_files/include/catkin_build.bash:/catkin_build.bash \
    --volume ${PWD}/include/install_detectron2.sh:/install_detectron2.sh \
    ${IMAGE_NAME}:base
