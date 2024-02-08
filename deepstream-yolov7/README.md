# Building Docker Image for NVIDIA Deepstream and Install Application

This repo provides a set of instructions for building a Docker image tailored for deploying a Deepstream application with support for YOLOv7 model inference served by Triton Server. It outlines the steps required to set up the environment and install necessary dependencies.


This repository build and install the sample app [deepstream-yolov7-triton-server-rtsp-out](https://github.com/levipereira/deepstream-yolov7-triton-server-rtsp-out)


### 1. Deploying the Docker Image 

To deploy the Docker image for Deepstream with YOLOv7 model support served by Triton Server, follow these steps:

Note: This script must be executed on the host operating system.

```bash
git clone https://github.com/levipereira/docker_images.git
cd ./docker_images/deepstream-yolov7/
bash ./build_deepstream_6.4-triton-server.sh
```

### 2. Starting Docker Image 
Script to start the Docker container for Deepstream with YOLOv7 model support served by Triton Server.

Note: This script must be executed on the host operating system.

``` bash
bash ./start_deepstream_container.sh
```
<br><br>
# DockerFile Documentation
### Base Image
The Dockerfile starts with a base image `nvcr.io/nvidia/deepstream:6.4-triton-multiarch`, which serves as the foundation for the custom image.

### Installing DeepStream Python Bindings
The Dockerfile run the script `user_deepstream_python_apps_install.sh` to install DeepStream Python Bindings with a specified version.

### Installing custom parse lib `NvDsInferYolov7EfficientNMS` for Gst-nvinferserver 
- The repository [nvdsinfer_yolov7_efficient_nms](https://github.com/levipereira/nvdsinfer_yolov7_efficient_nms) is cloned from GitHub into the `/tmp` directory.
- The contents of the repository are then copied to the DeepStream sources directory (`/opt/nvidia/deepstream/deepstream/sources/libs/`).
- The custom library is built and installed using the provided Makefile.

### Install Application `deepstream-yolov7-triton-server-rtsp-out` to Docker
- A directory `/deepstream_python_apps/apps/` is created within the Docker image.
- Git Clone `https://github.com/levipereira/deepstream-yolov7-triton-server-rtsp-out`
- The DeepStream application files (`deepstream-yolov7-triton-server-rtsp-out`) are copied into the created directory.
- The working directory is set to the copied application directory.

 
