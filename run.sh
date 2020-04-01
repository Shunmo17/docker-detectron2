#!/bin/bash

# Default settings
PROGNAME="$( basename $0 )"
IMAGE_NAME="detectron2"
SSH="false"
GPU_NUMBER="0"

# Usage
function usage() {
  cat << EOS >&2
Usage:
   ${PROGNAME} [-g, --gpu]
Options:
  -g, --gpu     Disignate gpu number.
                If not disignated, select gpu 0.
  -h, --help    Show usage.
EOS
  exit 1
}

# Get Option
PARAM=()
for opt in "$@"; do
    case "${opt}" in
        '-g' | '--gpu' )
            GPU=true; shift
            if [[ -n "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                GPU_NUMBER="$1"; shift
            fi
            ;;
        '-h' | '--help' )
            usage
            ;;
        '--' | '-' )
            shift
            PARAM+=( "$@" )
            break
            ;;
        -* )
            echo "${PROGNAME}: illegal option -- '$( echo $1 | sed 's/^-*//' )'" 1>&2
            exit 1
            ;;
        * )
            if [[ -n "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                PARAM+=( "$1" ); shift
            fi
            ;;
    esac
done

echo "===================="
echo "| GPU Number : ${GPU_NUMBER} |"
echo "===================="

NV_GPU=${GPU_NUMBER} \
nvidia-docker run \
    -it --rm \
    --runtime=nvidia \
    --net host \
    --privileged \
    --env DISPLAY=${DISPLAY} \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume ${HOME}/.Xauthority:/root/.Xauthority \
    --volume ${PWD}/common_files/include/alias.sh:/alias.sh \
    --volume ${PWD}/common_files/include/config:/root/.config/terminator/config \
    --volume ${PWD}/common_files/include/ros_setting.sh:/ros_setting.sh \
    --volume ${PWD}/common_files/include/ros_entrypoint.sh:/ros_entrypoint.sh \
    --volume ${PWD}/common_files/include/catkin_build.bash:/catkin_build.bash \
    --volume ${PWD}/../../ros_packages/detectron2_ros:/catkin_ws/src/detectron2 \
    ${IMAGE_NAME}:rev01