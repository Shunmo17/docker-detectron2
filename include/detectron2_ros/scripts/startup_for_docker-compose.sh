#! /bin/bash

# instead of "source ~/.bashrc"
# source /ros_entrypoint.sh
source /alias.sh
source /ros_setting.sh
source /catkin_build.bash

# roslaunch
roslaunch detectron2_ros detectron2_ros.launch cam_index:=${CAM_NUMBER}