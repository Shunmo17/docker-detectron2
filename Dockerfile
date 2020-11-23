##############################################################################
##                                 Base Image                               ##
##############################################################################
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

##############################################################################
##                                  Detectron                               ##
##############################################################################
# # install cuda
# ENV CUDA_VERSION 10-1
# ENV CUDNN_VERSION 7
# RUN apt update && apt install -y software-properties-common
# RUN add-apt-repository ppa:graphics-drivers
# RUN apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
# RUN echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" >> /etc/apt/sources.list.d/cuda.list
# RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" >> /etc/apt/sources.list.d/cuda_learn.list

# RUN apt update && apt install -y \
#     cuda-${CUDA_VERSION} libcudnn${CUDNN_VERSION}
# RUN echo "export PATH=`/usr/local/cuda/bin:\${PATH}`" >> ~/.bashrc \
#     && echo "LD_LIBRARY_PATH='/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}'" >> ~/.bashrc

# # install cudnn
# # RUN echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" | tee /etc/apt/sources.list.d/nvidia-ml.list
# # RUN apt update && apt install -y \
# #     libcudnn7-dev=7.5.0.56-1+cuda10.0

# RUN apt update && apt-get install -y \
#     python3-pip \
#     git \
#     python3.7
# RUN pip3 install \
#     torch==1.4.0+cu100 \
#     torchvision==0.5.0+cu100 -f https://download.pytorch.org/whl/torch_stable.html
# RUN pip3 install cython pyyaml==5.1 && \
#     pip3 install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' && \
#     pip3 install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu100/index.html && \
#     pip3 install opencv-python && \
#     pip3 install rospkg
# RUN echo "workon detectron2_ros" >> ~/.bashrc && \
#     echo "source /startup.sh" >> ~/.bashrc

# # install ros_numpy
# RUN apt update && apt install -y \
#     python-numpy

# RUN apt update && apt install -y software-properties-common
# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# RUN mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
# RUN add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
# RUN apt update && apt -y install cuda

RUN apt update && apt install -y \
    python3-pip \
    git \
    python3.8 \
    python3-numpy
RUN pip3 install \
    torch==1.7.0 \
    torchvision==0.8.0 \
    opencv-python \
    cython \
    pyyaml==5.1 \
    rospkg \
    detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu110/torch1.7/index.html
RUN pip3 install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

##############################################################################
##                              bashrc setting                              ##
##############################################################################
# terminal text
RUN echo "export PS1='\[\e[1;31;47m\]DETECTRON2\[\e[0m\] \[\e[1;37;46m\]\${ROS_MASTER_MODE}\[\e[0m\] \u:\w\$ '">> ~/.bashrc