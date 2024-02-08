#!/bin/bash

# Script to convert ONNX models to TensorRT engines and start NVIDIA Triton Inference Server.

# Usage:
# ./convert_and_start_triton.sh <max_batch_size> <opt_batch_size> [--force-build]
# - max_batch_size: Maximum batch size for TensorRT engines.
# - opt_batch_size: Optimal batch size for TensorRT engines.
# - Use the flag --force-build to rebuild TensorRT engines even if they already exist.

# Prerequisites:
# - NVIDIA TensorRT must be installed.
# - NVIDIA Triton Inference Server must be installed and configured.

# Function to calculate the available GPU memory
function get_free_gpu_memory() {
    # Get the total memory and used memory from nvidia-smi
    local total_memory=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{print $1}')
    local used_memory=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{print $1}')

    # Calculate free memory
    local free_memory=$((total_memory - used_memory))
    echo "$free_memory"
}

# Script Flow:

max_batch_size="$1"
opt_batch_size="$2"

# Validate input parameters
if [[ -z $max_batch_size || -z $opt_batch_size ]]; then
    echo "Error: Please provide max_batch_size and opt_batch_size as input parameters."
    exit 1
fi

if [[ $max_batch_size -lt $opt_batch_size ]]; then
    echo "Error: max_batch_size must be greater than or equal to opt_batch_size."
    exit 1
fi

if [[ ! -f "./models_onnx/yolov7/yolov7_end2end.onnx" || ! -f "./models_onnx/yolov7_qat/yolov7_qat_end2end.onnx" ]]; then
    echo "YOLOv7 ONNX model files not found. Attempting to download..."
    cd ./models_onnx || exit 1
    bash ./download_models.sh
    cd ../ || exit 1
fi

# Check if ONNX model files exist
if [[ ! -f "./models_onnx/yolov7/yolov7_end2end.onnx" ]]; then
    echo "YOLOv7 ONNX model file not found: ./models_onnx/yolov7/yolov7_end2end.onnx"
    exit 1
fi

if [[ ! -f "./models_onnx/yolov7_qat/yolov7_qat_end2end.onnx" ]]; then
    echo "YOLOv7 QAT ONNX model file not found: ./models_onnx/yolov7_qat/yolov7_qat_end2end.onnx"
    exit 1
fi

# Check if force-build flag is set
force_build=false

if [[ "$3" == "--force-build" ]]; then
    force_build=true
fi

# Calculate workspace size based on free GPU memory
workspace=$(get_free_gpu_memory)

mkdir -p ./models/yolov7/1/
mkdir -p ./models/yolov7_qat/1/

# Convert YOLOv7 ONNX model to TensorRT engine with FP16 precision if force flag is set or model does not exist
if [[ $force_build == true || ! -f "./models/yolov7/1/model.plan" ]]; then
    /usr/src/tensorrt/bin/trtexec \
        --onnx=./models_onnx/yolov7/yolov7_end2end.onnx \
        --minShapes=images:1x3x640x640 \
        --optShapes=images:${opt_batch_size}x3x640x640 \
        --maxShapes=images:${max_batch_size}x3x640x640 \
        --fp16 \
        --workspace=$workspace \
        --saveEngine=./models/yolov7/1/model.plan

    # Check return code of trtexec
    if [[ $? -ne 0 ]]; then
        echo "Conversion of YOLOv7 ONNX model to TensorRT engine failed"
        exit 1
    fi
fi

# Convert YOLOv7 QAT ONNX model to TensorRT engine with INT8 precision if force flag is set or model does not exist
if [[ $force_build == true || ! -f "./models/yolov7_qat/1/model.plan" ]]; then
    /usr/src/tensorrt/bin/trtexec \
        --onnx=./models_onnx/yolov7_qat/yolov7_qat_end2end.onnx \
        --minShapes=images:1x3x640x640 \
        --optShapes=images:${opt_batch_size}x3x640x640 \
        --maxShapes=images:${max_batch_size}x3x640x640 \
        --fp16 \
        --int8 \
        --workspace=$workspace \
        --saveEngine=./models/yolov7_qat/1/model.plan

    # Check return code of trtexec
    if [[ $? -ne 0 ]]; then
        echo "Conversion of YOLOv7 QAT ONNX model to TensorRT engine failed"
        exit 1
    fi
fi

### Deploy proto config File.
config_file=./models/yolov7/config.pbtxt
if [[ ! -f "$config_file" ]]; then
    cp ./models_config/yolov7/config.pbtxt "$config_file"
fi
sed -i "s/max_batch_size: [0-9]*/max_batch_size: $max_batch_size/" "$config_file"
echo "max_batch_size updated to $max_batch_size in $config_file"

config_file=./models/yolov7_qat/config.pbtxt
if [[ ! -f "$config_file" ]]; then
    cp ./models_config/yolov7_qat/config.pbtxt "$config_file"
fi

sed -i "s/max_batch_size: [0-9]*/max_batch_size: $max_batch_size/" "$config_file"
echo "max_batch_size updated to $max_batch_size in $config_file"

# Start Triton Inference Server with the converted models
/opt/tritonserver/bin/tritonserver \
    --model-repository=/apps/models \
    --disable-auto-complete-config \
    --log-verbose=0
