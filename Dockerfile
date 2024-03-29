##############################################################################
##                                 Base Image                               ##
##############################################################################
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

##############################################################################
##                                  Detectron                               ##
##############################################################################
# install dependencies
RUN pip3 install -U torch==1.7+cu110 \torchvision==0.8.1+cu110 -f \
    https://download.pytorch.org/whl/torch_stable.html
RUN pip3 install --ignore-installed cython pyyaml==5.1
RUN pip3 install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

RUN python3 -m pip install detectron2 -f \
  https://dl.fbaipublicfiles.com/detectron2/wheels/cu110/torch1.7/index.html
RUN pip3 install opencv-python rospkg

# clone ros_numpy
WORKDIR /catkin_ws/src
RUN git clone https://github.com/eric-wieser/ros_numpy.git -b 0.0.4

# # clone detectron2
# RUN mkdir /catkin_ws/src/detectron2_ros
# WORKDIR /catkin_ws/src/detectron2_ros
# RUN git clone https://github.com/facebookresearch/detectron2 -b master

# to send Compressed Image
RUN apt update && apt install -y \
  ros-noetic-image-transport \
  ros-noetic-image-transport-plugins

# set automatically starting detectron2 node
RUN echo "source /startup.sh" >> ~/.bashrc

##############################################################################
##                              bashrc setting                              ##
##############################################################################
# terminal text
RUN echo "export PS1='\[\e[1;31;47m\]DETECTRON2\[\e[0m\] \[\e[1;37;46m\]\${ROS_MASTER_MODE}\[\e[0m\] \u:\w\$ '">> ~/.bashrc