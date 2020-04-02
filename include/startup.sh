#! /bin/bash

if [ $CAM_NUMBER = "unspecified" ]; then
    if [ $TEST_ENABLE = "false" ]; then
        echo "***** ERROR *****"
        echo "Please specify camera number, or use test option."
        echo "specify camera number : -c CAM_NUMBER"
        echo "use test option : -t or --test"
    fi
    if [ $TEST_ENABLE = "true" ]; then
        echo "Test Mode was specifed."
    fi
fi
if [ $CAM_NUMBER = 0 ]; then
    roslaunch detectron2_ros env_cam00.launch
fi
if [ $CAM_NUMBER = 1 ]; then
    roslaunch detectron2_ros env_cam01.launch
fi
if [ $CAM_NUMBER = 2 ]; then
    roslaunch detectron2_ros env_cam02.launch
fi
if [ $CAM_NUMBER = 3 ]; then
    roslaunch detectron2_ros env_cam03.launch
fi
if [ $CAM_NUMBER = 4 ]; then
    roslaunch detectron2_ros env_cam04.launch
fi
if [ $CAM_NUMBER = 5 ]; then
    roslaunch detectron2_ros env_cam05.launch
fi