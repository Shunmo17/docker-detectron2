#! /bin/bash

# instead of "source ~/.bashrc"
# source /ros_entrypoint.sh
source /alias.sh
source /ros_setting.sh
source /catkin_build.bash

# change to virtual environemnt to use python3
. /usr/local/bin/virtualenvwrapper.sh
workon detectron2_ros

# roslaunch
roslaunch detectron2_ros detectron2_ros.launch cam_index:=${CAM_NUMBER}