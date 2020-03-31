## Description

Mask R-CNN for ROSを動かすためのDockerです。



## Docker

### original image
nvidia/cuda:10.0-devel-ubuntu16.04

### ros version

kinetic

### common tools
* iproute2
* iputils-ping
* net-tools
* terminator
* nautilus
* gedit

### ubuntu additional packages

NONE

### ros additional packages

ros-kinetic-ros-numpy



## Requirement

* NVIDIA GPUを搭載したPC

* NVIDIA Docker

  

## Usage

### Build

```
./build.sh
```



### Run

```
./run.sh -g [GPU_NUMBER]
```





## Author

Shunmo17