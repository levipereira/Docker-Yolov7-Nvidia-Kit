# Use the official NVIDIA PyTorch image as the base image
FROM nvcr.io/nvidia/pytorch:23.02-py3

# Update and install required dependencies
RUN apt-get update \
    && apt-get install -y zip htop screen libgl1-mesa-glx graphviz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install necessary Python packages
RUN pip install --upgrade pip \
    && pip install seaborn \
                   thop \
                   markdown-it-py==2.2.0 \
                   onnx-simplifier==0.4.35 \
                   onnxsim==0.4.35 \
                   onnxruntime==1.16.3 \
                   pycuda==2024.1 \
                   ujson==5.9.0 \
                   pycocotools==2.0.7 \
                   virtualenv \
                   widgetsnbextension==4.0.9

RUN mkdir -p /opt/nvidia_trex 

# Create and activate a virtual environment Clone TensorRT repository and install trt-engine-explorer (trex)
RUN cd /opt/nvidia_trex/ \
    && python3 -m virtualenv env_trex \
    && /bin/bash -c "source env_trex/bin/activate && pip install Werkzeug==2.2.2 graphviz==0.20.1" \
    && cd /opt/nvidia_trex/ \
    && git clone https://github.com/NVIDIA/TensorRT.git \
    && cd TensorRT \
    && git checkout release/8.6 \
    && cd tools/experimental/trt-engine-explorer \
    && /bin/bash -c "source /opt/nvidia_trex/env_trex/bin/activate && pip install -e ." \
    && /bin/bash -c "source /opt/nvidia_trex/env_trex/bin/activate && jupyter nbextension enable widgetsnbextension --user --py"


## Deploy yolov7
RUN cd / \
    && git clone https://github.com/levipereira/yolov7.git

## Patch yolov7 with yolo_qat 
RUN  cd /tmp/ \
     && git clone https://github.com/levipereira/yolo_deepstream.git \
     && cd /tmp/yolo_deepstream/yolov7_qat \
     && cp -R doc quantization scripts /yolov7/ \
     && cd /tmp \
     && rm -rf /tmp/yolo_deepstream

# Set working directory
WORKDIR /yolov7


# 'python3 scripts/qat.py quantize  experiments/yolov7.pt --data data/coco.yaml --img-size 640 --hyp data/hyp.scratch.p5.yaml --ptq ptq.pt --qat qat.pt --eval-origin --eval-ptq '
# 