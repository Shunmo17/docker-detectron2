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

from detectron2.utils.visualizer import ColorMode
from detectron2.config import get_cfg
from detectron2.data.datasets import register_coco_instances

from detectron2.engine import DefaultTrainer

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
#   Hyper Parameters
# =============================================================
ITERRAITON_NUM = [9000]
# 1/100, 1/500
LERNING_RATE = [0.00005]

# document : https://detectron2.readthedocs.io/_modules/detectron2/data/datasets/register_coco.html
register_coco_instances(TRAIN_DATA_NAME, {}, JSON_FILE, IMAGE_DIR)

cfg = get_cfg()
for iteration_num in ITERRAITON_NUM:
    for learning_rate in LERNING_RATE:
        print("========= Traing Start =========")
        print("Json File : {}".format(JSON_FILE))
        print("Image Directory : {}".format(IMAGE_DIR))
        print("Iteration Num : {}".format(iteration_num))
        print("Learning Rate : {}".format(learning_rate))
        print("================================")

        cfg.merge_from_file(ORIGINAL_CFG_FILE)
        cfg.DATASETS.TRAIN = (TRAIN_DATA_NAME,)
        cfg.DATASETS.TEST = ()
        cfg.DATALOADER.NUM_WORKERS = 2
        cfg.MODEL.WEIGHTS = ORIGINAL_WEIGHT_FILE
        cfg.SOLVER.IMS_PER_BATCH = 2
        cfg.SOLVER.BASE_LR = learning_rate
        cfg.SOLVER.MAX_ITER = iteration_num
        cfg.MODEL.ROI_HEADS.BATCH_SIZE_PER_IMAGE = 128
        cfg.MODEL.ROI_HEADS.NUM_CLASSES = 80
        cfg.OUTPUT_DIR = OUTPUT_DIR

        os.makedirs(cfg.OUTPUT_DIR, exist_ok=True)
        trainer = DefaultTrainer(cfg) 
        trainer.resume_or_load(resume=False)
        trainer.train()
        
        # save weight file
        os.system("chmod 777 {}/model_final.pth".format(OUTPUT_DIR))
        os.system("mv {}/model_final.pth {}/{}.pth".format(OUTPUT_DIR, OUTPUT_DIR, ORIGINAL_MODEL_NAME + "_iter_" + str(iteration_num) + "_learn_" + str(learning_rate)))
        
        # save log file
        folder_name = (ORIGINAL_MODEL_NAME + "_iter_" + str(iteration_num) + "_learn_" + str(learning_rate)).replace(".", "-")
        os.system("mkdir ./../weights/COCO-InstanceSegmentation/{}".format(folder_name))
        os.system("mv ./../weights/COCO-InstanceSegmentation/events* ./../weights/COCO-InstanceSegmentation/{}/".format(folder_name))
        os.system("chmod 777 -R ./../weights/COCO-InstanceSegmentation/*  ")

        print("========= Traing Finished =========")
        print("Json File : {}".format(JSON_FILE))
        print("Image Directory : {}".format(IMAGE_DIR))
        print("Iteration Num : {}".format(iteration_num))
        print("Learning Rate : {}".format(learning_rate))
        print("===================================")

os.system("ls ./../weights/COCO-InstanceSegmentation")
# os.system("tensorboard --logdir {}".format(OUTPUT_DIR))
