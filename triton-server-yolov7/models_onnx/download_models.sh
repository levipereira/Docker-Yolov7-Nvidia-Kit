#!/bin/bash

# Create directories if they do not exist
mkdir -p ./yolov7
mkdir -p ./yolov7_qat

# Download YOLOv7 ONNX model
echo "Downloading YOLOv7 ONNX model..."
wget -O ./yolov7/yolov7_end2end.onnx https://github.com/levipereira/triton-server-yolov7/releases/download/v0.1/yolov7_end2end.onnx

# Check if download was successful
if [[ $? -eq 0 ]]; then
    echo "YOLOv7 ONNX model downloaded successfully."
else
    echo "Failed to download YOLOv7 ONNX model."
    exit 1
fi

# Download YOLOv7 QAT ONNX model
echo "Downloading YOLOv7 QAT ONNX model..."
wget -O ./yolov7_qat/yolov7_qat_end2end.onnx https://github.com/levipereira/triton-server-yolov7/releases/download/v0.1/yolov7_qat_end2end.onnx

# Check if download was successful
if [[ $? -eq 0 ]]; then
    echo "YOLOv7 QAT ONNX model downloaded successfully."
else
    echo "Failed to download YOLOv7 QAT ONNX model."
    exit 1
fi
