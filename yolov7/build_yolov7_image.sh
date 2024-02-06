tag_name="yolov7_qat"
image_name="local/nvidia_yolov7:${tag_name}"
docker build --no-cache -t $image_name -f  Dockerfile  .
