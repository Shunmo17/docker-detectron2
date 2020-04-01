## Description

Docker for Detectron2 on ROS



## Docker

### Original Image
nvidia/cuda:10.1-devel-ubuntu18.04

### ROS Version

melodic



## Requirement

* NVIDIA GPUを搭載したPC

* NVIDIA Docker

  

## Usage

### Build

making docker base image

```
./build.sh
```



### Run for docker commit

#### run

```
./run.sh
```

#### install detectron2 on Docker

```
apt-get update && apt-get install -y \
    python-pip \
    git \
    python3.7 \
    python3-virtualenv && \
pip install virtualenv && \
mkdir ~/.virtualenvs && \
pip install virtualenvwrapper && \
export WORKON_HOME=~/.virtualenvs && \
echo '. /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc && \
source ~/.bashrc && \
mkvirtualenv --python=python3 detectron2_ros && \
pip install -U torch==1.4+cu100 torchvision==0.5+cu100 -f https://download.pytorch.org/whl/torch_stable.html && \
pip install cython pyyaml==5.1 && \
pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' && \
pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu100/index.html && \
pip install opencv-python && \
pip install rospkg
```

#### save container as image

```
docker commmit [CONTAINER ID] detectron2:latest
```



## Author

Shunmo17