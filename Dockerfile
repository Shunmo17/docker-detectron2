##############################################################################
##                                 Base Image                               ##
##############################################################################
# https://gitlab.com/nvidia/cuda/blob/master/dist/ubuntu16.04/10.1/devel/cudnn7/Dockerfile

FROM nvidia/cuda:10.0-devel-ubuntu16.04

ENV CUDNN_VERSION 7.4.2.24

# change server for apt-get
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
    libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 \
    && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

##############################################################################
##                     ROS Kinetic-Desktop-Full Install                     ##
##############################################################################
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros1-latest.list

# install ros
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop-full \
    && rm -rf /var/lib/apt/lists/*
    
# initiliaze rosdep
RUN rosdep init && rosdep update
RUN rosdep fix-permissions

# set entrypoint
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

##############################################################################
##                              ROS Initialize                              ##
##############################################################################
RUN mkdir -p /catkin_ws/src

# for catkin build
RUN apt-get update && apt-get install -y \
    python-catkin-tools

# for solving build error
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /catkin_ws
RUN	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin init"

RUN echo "source /ros_setting.sh" >> ~/.bashrc && \
    echo "source /catkin_build.bash" >> ~/.bashrc

##############################################################################
##                                  Common                                  ##
##############################################################################
# install ifconfig & ping
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    net-tools \
    terminator \
    nautilus \
    gedit \
    vim \
    && rm -rf /var/lib/apt/lists/*

# install pip (after ver3.4 : pip is installed)
RUN apt-get update && apt-get install -y \
    wget && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py

## fix terminator error
RUN apt-get update && apt-get install -y \
    dbus-x11

# aiias
RUN echo "source /alias.sh">> ~/.bashrc

##############################################################################
##                                  Detectron                               ##
##############################################################################
# ref https://github.com/DavidFernandezChaves/Detectron2_ros
# Python v3.6 (in virtual environment)
RUN apt-get update && apt-get install -y \
    software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.6 \
    python3-virtualenv
RUN apt-get update && apt-get install -y python-pip

# RUN pip install --upgrade pip
RUN pip install virtualenv
RUN mkdir ~/.virtualenvs
RUN pip install virtualenvwrapper
RUN export WORKON_HOME=~/.virtualenvs
RUN echo '. /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc 

# create virtual environment
## ref : https://github.com/NeuralEnsemble/pype9/blob/master/Dockerfile
# RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh; mkvirtualenv --python=python3 detectron2_ros"
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh; python3 -m virtualenv --python=/usr/bin/python3 /opt/venv"

# install git
RUN apt-get update && apt-get install -y git

# install dependencies
RUN /opt/venv/bin/pip install -U torch==1.4+cu100 torchvision==0.5+cu100 -f https://download.pytorch.org/whl/torch_stable.html
RUN /opt/venv/bin/pip install --ignore-installed cython pyyaml==5.1
RUN /opt/venv/bin/pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

RUN python --version

RUN /opt/venv/bin/pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu100/index.html
RUN /opt/venv/bin/pip install opencv-python
RUN /opt/venv/bin/pip install rospkg

##############################################################################
##                              bashrc setting                              ##
##############################################################################
# terminal text
RUN echo "export PS1='\[\e[1;31;40m\]MASK_R-CNN\[\e[0m\] \u:\w\$ '">> ~/.bashrc