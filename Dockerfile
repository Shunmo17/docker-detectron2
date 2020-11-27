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

# clone detectron2
RUN mkdir /catkin_ws/src/detectron2_ros
WORKDIR /catkin_ws/src/detectron2_ros
RUN git clone https://github.com/facebookresearch/detectron2 -b master

# download models 
# RUN mkdir /MODEL_ZOO
# WORKDIR /MODEL_ZOO
# RUN wget -O mask_rcnn_X_101_32x8d_FPN_3x.pkl https://dl.fbaipublicfiles.com/detectron2/COCO-InstanceSegmentation/mask_rcnn_X_101_32x8d_FPN_3x/139653917/model_final_2d9806.pkl && \
#     wget -O mask_rcnn_R_101_FPN_3x.pkl https://dl.fbaipublicfiles.com/detectron2/COCO-InstanceSegmentation/mask_rcnn_R_101_FPN_3x/138205316/model_final_a3ec72.pkl && \
#     wget -O mask_rcnn_R_101_DC5_3x.pkl https://dl.fbaipublicfiles.com/detectron2/COCO-InstanceSegmentation/mask_rcnn_R_101_DC5_3x/138363294/model_final_0464b7.pkl && \
#     wget -O mask_rcnn_R_101_C4_3x.pkl https://dl.fbaipublicfiles.com/detectron2/COCO-InstanceSegmentation/mask_rcnn_R_101_C4_3x/138363239/model_final_a2914c.pkl && \
#     wget -O mask_rcnn_R_50_FPN_3x.pkl https://dl.fbaipublicfiles.com/detectron2/COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x/137849600/model_final_f10217.pkl

# set automatically starting detectron2 node
RUN echo "source /startup.sh" >> ~/.bashrc

##############################################################################
##                              bashrc setting                              ##
##############################################################################
# terminal text
RUN echo "export PS1='\[\e[1;31;47m\]DETECTRON2\[\e[0m\] \[\e[1;37;46m\]\${ROS_MASTER_MODE}\[\e[0m\] \u:\w\$ '">> ~/.bashrc