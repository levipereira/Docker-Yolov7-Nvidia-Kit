#!/bin/bash

# Script to run the Docker container for Deepstream with YOLOv7 model support served by Triton Server.

# Usage:
# Run this script to start the Docker container.
# Make sure to replace "$(pwd)\media" with the absolute path to your media directory.

# Options:
# --gpus all: Utilize all available GPUs.
# -it: Launch the container interactively.
# --rm: Remove the container when it exits.
# --net host: Use the host network stack.
# --ipc=host: Use host IPC namespace.
# --ulimit memlock=-1: Remove memory locking limit.
# --ulimit stack=67108864: Set stack size limit.
# -v $(pwd)\videos:/deepstream_python_apps/apps/deepstream-yolov7-triton-server-rtsp-out/videos: Mount the local videos directory to the container.

docker run --gpus all \
    -it \
    --rm \
    --net host \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v $(pwd)\videos:/deepstream_python_apps/apps/deepstream-yolov7-triton-server-rtsp-out/videos \
    local/nvidia:deepstream_6.4-triton-server
