#! /bin/bash

# catkin build
cd /catkin_ws && catkin build && \

# path
source /catkin_ws/devel/setup.bash && \

# change to virtual environemnt to use python3
. /usr/local/bin/virtualenvwrapper.sh && \
workon detectron2_ros && \

# roslauch
roslaunch detectron2_ros detectron2_ros.launch cam_index:=${CAM_NUMBER}