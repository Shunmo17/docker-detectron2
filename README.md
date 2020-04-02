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

Make docker base image.

```
./build.sh
```



### docker commit

The docker image you made above is NOT a docker where you can run detectron2. You have to install detectron2 after running base docker, and commit to save the container as image.

#### run

```
./run_for_docker-commit.sh
```



#### install detectron2 on Docker

Run the `/include/install_detectron2.sh` in the base docker.



#### save container as image

```
docker ps
```

Take note container name. Then, run the below scripts.

```
docker commmit [CONTAINER ID] detectron2:latest
```



### Run

```
./run.sh
```





## Author

Shunmo17