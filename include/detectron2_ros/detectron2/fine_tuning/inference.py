# Some basic setup:
# Setup detectron2 logger
import detectron2
from detectron2.utils.logger import setup_logger
setup_logger()

# import some common libraries
import numpy as np
import os, json, cv2, random

# import some common detectron2 utilities
from detectron2 import model_zoo
from detectron2.engine import DefaultPredictor
from detectron2.config import get_cfg
from detectron2.utils.visualizer import Visualizer
from detectron2.data import MetadataCatalog, DatasetCatalog
from detectron2.data.datasets import register_coco_instances

from detectron2.utils.visualizer import ColorMode
from detectron2.config import get_cfg

# =============================================================
#   Train Data Settings
# =============================================================
# Train Data
TRAIN_DATA_NAME = "07_304_train"
JSON_FILE = "./train_data/trainval.json"
IMAGE_DIR = "./train_data/images"

# Orignal Network Model
ORIGINAL_MODEL_NAME = "mask_rcnn_R_101_FPN_3x"
ORIGINAL_CFG_FILE = "./../configs/COCO-InstanceSegmentation/" + ORIGINAL_MODEL_NAME + ".yaml"
ORIGINAL_WEIGHT_FILE = "./../weights/COCO-InstanceSegmentation/" + ORIGINAL_MODEL_NAME + ".pkl"

# Output Setting
OUTPUT_DIR = "./../weights/COCO-InstanceSegmentation"

# =============================================================
#   Inference Settings
# =============================================================
# Network Model
MODEL_DIR = "./../weights/COCO-InstanceSegmentation"
BASE_MODEL_NAME = "mask_rcnn_R_101_FPN_3x"
MODEL_NAME = "mask_rcnn_R_101_FPN_3x_iter_300_learn_00025"
WEIGHT_FILE = MODEL_DIR + "/" + MODEL_NAME + ".pth"

# Image for Inference
IMAGE = "./train_data/images/0047.jpg"
# IMAGE = "./inference_data/ishihara_satomi.jpg"

register_coco_instances(TRAIN_DATA_NAME, {}, JSON_FILE, IMAGE_DIR)
meta_data = MetadataCatalog.get(TRAIN_DATA_NAME)
dataset_dicts = DatasetCatalog.get(TRAIN_DATA_NAME)
# print(dataset_dicts)

cfg = get_cfg()
cfg.merge_from_file(model_zoo.get_config_file("COCO-InstanceSegmentation/mask_rcnn_R_101_FPN_3x.yaml"))
cfg.MODEL.ROI_HEADS.NUM_CLASSES = 80  # only has one class (ballon)
cfg.MODEL.WEIGHTS = WEIGHT_FILE
cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.7   # set a custom testing threshold
predictor = DefaultPredictor(cfg)

im = cv2.imread(IMAGE)
outputs = predictor(im)  # format is documented at https://detectron2.readthedocs.io/tutorials/models.html#model-output-format
v = Visualizer(im[:, :, ::-1],
                metadata=meta_data, 
                scale=1.0, 
                instance_mode=ColorMode.IMAGE_BW   # remove the colors of unsegmented pixels. This option is only available for segmentation models
)
out = v.draw_instance_predictions(outputs["instances"].to("cpu"))
cv2.imshow("img", out.get_image()[:, :, ::-1])
cv2.waitKey(0)
