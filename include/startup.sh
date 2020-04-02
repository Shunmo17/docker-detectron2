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
roslaunch detectron2_ros detectron2_ros.launch camera_index:= $CAM_NUMBER