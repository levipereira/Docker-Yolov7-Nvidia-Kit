# Triton Server  YOLOv7 / Yolov7 QAT  

This repository serves as an example of deploying the Models YOLOv7 model (FP16) and the YOLOv7 QAT   (INT8) on Triton-Server for performance and testing. It includes support for applications developed using Nvidia DeepStream. 

Instructions to deploy YOLOv7 as TensorRT engine to [Triton Inference Server](https://github.com/NVIDIA/triton-inference-server).

This Repo use exported Yolov7 Models ONNX to Generate TensorRT Engine.

Users can either build ONNX files themselves  or simply utilize the [start-container-triton-server.sh](start-container-triton-server.sh) script to initiate the container and use [start-triton-server.sh](start-triton-server.sh) to download the models, generate the TRT engine, and start the Triton Server.

This repository is a continuation of [philipp-schmidt](https://github.com/WongKinYiu/yolov7/commits?author=philipp-schmidt) work in the repository https://github.com/WongKinYiu/yolov7/tree/main/deploy/triton-inference-server.  


## Exporting from PyTorch (YOLOv7 FP16) to ONNX With Efficient NMS plugin
This repo does not export pytorch models to ONNX. <br>
You can use the [Yolov7 Repository](https://github.com/WongKinYiu/yolov7) or the [Yolov7 Docker Image](https://github.com/levipereira/docker_images/tree/master/yolov7) for your convenience.

``` bash 
python export.py --weights yolov7.pt \
  --grid \
  --end2end \
  --dynamic-batch \
  --simplify \
  --topk-all 100 \
  --iou-thres 0.65 \
  --conf-thres 0.35 \
  --img-size 640 640
```

## Exporting from PyTorch (YOLOv7 QAT )  to ONNX With Efficient NMS plugin
This repo does not export pytorch models to ONNX. <br>
You can use the [Yolov7 QAT Repository](https://github.com/levipereira/yolo_deepstream/tree/main/yolov7_qat) or the [Yolov7 Docker Image](https://github.com/levipereira/docker_images/tree/master/yolov7) for your convenience.

``` bash 
python scripts/qat.py export qat.pt \
  --save=qat.onnx \
  --dynamic \
  --img-size 640 \
  --end2end \
  --topk-all 100 \
  --simplify \
  --iou-thres 0.65 \
  --conf-thres 0.35
```



## Running NVIDIA Triton Inference Server Container with Docker

### Usage

``` bash
bash ./start-container-triton-server.sh
```

Run this script to start the Triton Inference Server container.

Note: This script must be executed on the host operating system.

### Prerequisites

- NVIDIA Docker must be installed.
- NVIDIA GPU(s) should be available.


## Deploying TensorRT Engine and Starting Triton-Server 

### Prerequisites

- Model exported from PyTorch to ONNX

This script `start-triton-server.sh` automatically download Yolov7 ONNX models from https://github.com/levipereira/Docker-Yolov7-Nvidia-Kit/releases/tag/v1.0

### Usage Script (start-triton-server.sh) :

``` bash
 Usage:
bash ./start-triton-server.sh  <max_batch_size> <opt_batch_size> [--force-build]

# - max_batch_size: Maximum batch size for TensorRT engines.
# - opt_batch_size: Optimal batch size for TensorRT engines.
# - Use the flag --force-build to rebuild TensorRT engines even if they already exist.
```
Example
``` bash
bash ./start-triton-server.sh  16 8 --force-build 
```
This script converts ONNX models to TensorRT engines and starts the NVIDIA Triton Inference Server.

Note: This script is intended to be executed from within the Docker Triton container.

### Script Flow:
1. Checks for the existence of YOLOv7 ONNX model files.
2. Downloads ONNX models if they do not exist.
2. Converts YOLOv7 ONNX model to TensorRT engine with FP16 precision.
3. Converts YOLOv7 Quantized and Aware Training (QAT) ONNX model to TensorRT engine with INT8 precision.
4. Updates the batch size configurations in the Triton Server config files.
5. Starts Triton Inference Server with the converted models.

<br>After running script, you can verify the availability of the model by checking this output::
``` bash
+------------+---------+--------+
| Model      | Version | Status |
+------------+---------+--------+
| yolov7     | 1       | READY  |
| yolov7_qat | 1       | READY  |
+------------+---------+--------+

```

## Model Configuration

``` bash 
triton-server-yolov7/
├── models_config
│   ├── yolov7
│   │   └── config.pbtxt
│   └── yolov7_qat
│       └── config.pbtxt
```


See [Triton Model Configuration Documentation](https://github.com/triton-inference-server/server/blob/main/docs/model_configuration.md#model-configuration) for more info.


Example of Yolo Configuration <br>

Note:<br>
* The values of 100 in the det_boxes/det_scores/det_classes arrays represent the topk-all.<br>
* The setting "max_queue_delay_microseconds: 30000" is optimized for a 30fps input rate.

```
name: "yolov7_qat"
platform: "tensorrt_plan"
max_batch_size: 8
input [
  {
    name: "images"
    data_type: TYPE_FP32
    dims: [ 3, 640, 640 ]
  }
]
output [
  {
    name: "num_dets"
    data_type: TYPE_INT32
    dims: [ 1 ]
  },
  {
    name: "det_boxes"
    data_type: TYPE_FP32
    dims: [ 100, 4 ]
  },
  {
    name: "det_scores"
    data_type: TYPE_FP32
    dims: [ 100 ]
  },
  {
    name: "det_classes"
    data_type: TYPE_INT32
    dims: [ 100 ]
  }
]
instance_group [
    {
      count: 2
      kind: KIND_GPU
      gpus: [ 0 ]
    }
]
version_policy: { latest: { num_versions: 1}}
dynamic_batching {
  max_queue_delay_microseconds: 30000
}

```

In the log you should see:

```
+--------+---------+--------+
| Model  | Version | Status |
+--------+---------+--------+
| yolov7 | 1       | READY  |
+--------+---------+--------+
```

## Performance with Model Analyzer

See [Triton Model Analyzer Documentation](https://github.com/triton-inference-server/server/blob/main/docs/model_analyzer.md#model-analyzer) for more info.


### Perfomance test using GPU RTX 4090 on AMD Ryzen 7 3700X 8-Core


Triton-Server config:  Max Batch Size 16  / 2 Instances
Test Report : <br>
[Yolov7 FP16](report_test_rtx_4090/output_triton_perf_yolov7_fp16.txt) - Best Result:  `Concurrency: 48, throughput: 1049.65 infer/sec, latency 45729 usec`<br>
[Yolov7 QAT (INT8)](report_test_rtx_4090/output_triton_perf_yolov7_qat.txt) - Best Result `Concurrency: 48, throughput: 1219.37 infer/sec, latency 39340 usec`

Example test for a maximum of 128 concurrent clients, starting with 8 clients and incrementing by 8, using shared memory. 



```bash
docker run -it --ipc=host --net=host nvcr.io/nvidia/tritonserver:23.08-py3-sdk /bin/bash

./install/bin/perf_analyzer -m yolov7_qat  -u 127.0.0.1:8001 -i grpc --shared-memory system --concurrency-range 8:128:8

# Result (truncated)
Inferences/Second vs. Client Average Batch Latency
Concurrency: 8, throughput: 146.657 infer/sec, latency 54498 usec
Concurrency: 16, throughput: 559.946 infer/sec, latency 28576 usec
Concurrency: 24, throughput: 561.719 infer/sec, latency 42684 usec
Concurrency: 32, throughput: 1009.66 infer/sec, latency 31695 usec
Concurrency: 40, throughput: 1013.22 infer/sec, latency 39475 usec
Concurrency: 48, throughput: 1219.37 infer/sec, latency 39340 usec
Concurrency: 56, throughput: 1220.32 infer/sec, latency 45875 usec
Concurrency: 64, throughput: 1220.29 infer/sec, latency 52430 usec
Concurrency: 72, throughput: 1220.26 infer/sec, latency 58979 usec
Concurrency: 80, throughput: 1220.3 infer/sec, latency 65533 usec
Concurrency: 88, throughput: 1220.29 infer/sec, latency 72078 usec
Concurrency: 96, throughput: 1220.3 infer/sec, latency 78639 usec
Concurrency: 104, throughput: 1220.28 infer/sec, latency 85189 usec
Concurrency: 112, throughput: 1220.29 infer/sec, latency 91745 usec
Concurrency: 120, throughput: 1220.29 infer/sec, latency 98297 usec
Concurrency: 128, throughput: 1220.26 infer/sec, latency 104851 usec

```


