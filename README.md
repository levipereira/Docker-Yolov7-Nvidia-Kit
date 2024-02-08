# docker_images
This repository provides an out-of-the-box deployment solution for creating an end-to-end procedure to train, deploy, and use Yolov7 models on Nvidia GPUs using Triton Server and Deepstream.

# Training and Quantize Yolov7
Use [yolov7](yolov7) folder <br>
This Repo sets up an environment for running NVIDIA PyTorch applications, focusing on training YOLOv7 models, including quantization and profiling for achieving optimal performance with minimal accuracy loss.
It deploys [YOLOv7](https://github.com/levipereira/yolov7.git) with [YOLO Quantization-Aware Training (QAT)](https://github.com/levipereira/yolo_deepstream.git) patched. It also installs the [TensorRT Engine Explorer (TREx)](https://developer.nvidia.com/blog/exploring-tensorrt-engines-with-trex/), which is a Python library and a set of Jupyter notebooks for exploring a TensorRT engine plan and its associated inference profiling data.

# Deploy Yolov7 Models using Triton-Server
Use [triton-server-yolov7](triton-server-yolov7) folder <br>
Docker Image to Build Yolov7 models on Triton-Server
This repository serves as an example of deploying the Models YOLOv7 model (FP16) and the YOLOv7 QAT   (INT8) on Triton-Server for performance and testing. It includes support for applications developed using Nvidia DeepStream. 
Instructions to deploy YOLOv7 as TensorRT engine to [Triton Inference Server](https://github.com/NVIDIA/triton-inference-server). 


# Deploy Deepstream and Test using Triton-Server
Use [deepstream-yolov7](deepstream-yolov7) folder <br>
This repo provides a set of instructions for building a Docker image tailored for deploying a Sample Deepstream application with support for YOLOv7 model inference served by Triton Server. 
