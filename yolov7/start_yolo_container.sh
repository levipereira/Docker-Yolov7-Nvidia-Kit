image_name="local/nvidia_yolov7:yolov7_qat"

docker run --gpus all  \
 -it \
 --net host  \
 --ipc=host \
 -v /dataset/coco_2017/dataset/coco/:/yolov7/coco \
 -v $(pwd)/experiments:/yolov7/experiments \
 -v $(pwd)/runs:/yolov7/runs \
 $image_name


# default dir yolo qat project -  /yolov7/experiments 
# default dir yolo project -  /yolov7/runs 
#  $(pwd)/coco:/yolov7/coco  - location of coco dataset /or custom dataset
