#!/usr/bin/env python3
import sys
import threading
import copy
import time

import cv2 as cv
import numpy as np
import rospy
import ros_numpy
from detectron2.config import get_cfg
from detectron2.data import MetadataCatalog
from cv_bridge import CvBridge, CvBridgeError
from detectron2.engine import DefaultPredictor
from detectron2.utils.logger import setup_logger
# from detectron2.utils.visualizer import Visualizer
from custom_modules.visualizer import Visualizer
from detectron2_ros_msgs.msg import Result
from sensor_msgs.msg import Image, CompressedImage, RegionOfInterest
from sensor_msgs.msg import PointCloud2
from detectron2 import model_zoo
import os, json, cv2, random
from detectron2.utils.visualizer import ColorMode
from detectron2.data.datasets import register_coco_instances
from detectron2.data import MetadataCatalog, DatasetCatalog

class Detectron2node(object):
    def __init__(self, _cam_index):
        setup_logger()

        self._bridge = CvBridge()
        self._last_img = None
        self._last_pcd = None
        self._pcd_tmp = None
        self._img_lock = threading.Lock()
        self._pcd_lock = threading.Lock()
        self._publish_rate = 100.0
        self._gen_image_from_pcd = rospy.get_param("/detectron2/toggle/generate_image_from_pcd")
        self._use_compressed_image = rospy.get_param("/detectron2/toggle/use_compressed_image")
        self._use_custom_model = rospy.get_param("/detectron2/toggle/use_custom_model/" + "/env_cam" + _cam_index)
        self._enable_quater_pcd = rospy.get_param("/detectron2/toggle/enable_quater_pcd")
        self._system_mode = rospy.get_param("/mode", "not_specified")

        # Topic name
        self.input_image = "/env_cam" + _cam_index + "/rgb/image_raw"
        self.input_compressed_image = "/env_cam" + _cam_index + "/rgb/image_raw/compressed"
        self.input_pcd = "/env_cam" + _cam_index + "/depth/points"
        self.output_visualization_topic = "/env_cam" + _cam_index + "/maskrcnn/visualization"
        self.output_result_topic = "/env_cam" + _cam_index + "/maskrcnn/result"

        # # get metadata for fine tuning
        # TRAIN_DATA_NAME = "07_304_train"
        # JSON_FILE = "/catkin_ws/src/detectron2_ros/detectron2/fine_tuning/train_data/trainval.json"
        # IMAGE_DIR = "/catkin_ws/src/detectron2_ros/detectron2/fine_tuning/train_data/images"
        # register_coco_instances(TRAIN_DATA_NAME, {}, JSON_FILE, IMAGE_DIR)
        # self.meta_data = MetadataCatalog.get(TRAIN_DATA_NAME)
        # dataset_dicts = DatasetCatalog.get(TRAIN_DATA_NAME)

        # Mask R-CNN settings
        self.cfg = get_cfg()
        self.cfg.merge_from_file(rospy.get_param("/detectron2/parameter/model"))
        self.cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = rospy.get_param("/detectron2/parameter/detection_threshold")  # set threshold for this model
        self.cfg.MODEL.ROI_HEADS.NUM_CLASSES = 80
        # use custom model
        if self._use_custom_model:
            self.cfg.MODEL.WEIGHTS = rospy.get_param("/detectron2/parameter/weight/custom")
        else:
            self.cfg.MODEL.WEIGHTS = rospy.get_param("/detectron2/parameter/weight/base")
        self.predictor = DefaultPredictor(self.cfg)
        self._class_names = MetadataCatalog.get(self.cfg.DATASETS.TRAIN[0]).get("thing_classes", None)
        # self._class_names = self.meta_data.get("thing_classes", None)
        self._visualization = rospy.get_param("/detectron2/toggle/visualization")
        
        # =================================================================================
        # Using when training
        # =================================================================================
        # TRAIN_DATA_NAME = "07_304_train"
        # JSON_FILE = "/catkin_ws/src/detectron2_ros/detectron2/fine_tuning/train_data/trainval.json"
        # IMAGE_DIR = "/catkin_ws/src/detectron2_ros/detectron2/fine_tuning/train_data/images"
        # register_coco_instances(TRAIN_DATA_NAME, {}, JSON_FILE, IMAGE_DIR)
        # meta_data = MetadataCatalog.get(TRAIN_DATA_NAME)
        # dataset_dicts = DatasetCatalog.get(TRAIN_DATA_NAME)
        # IMAGE = "/catkin_ws/src/detectron2_ros/detectron2/fine_tuning/train_data/images/0047.jpg"
        # im = cv2.imread(IMAGE)
        # outputs = self.predictor(im)  # format is documented at https://detectron2.readthedocs.io/tutorials/models.html#model-output-format
        # v = Visualizer(im[:, :, ::-1],
        #                 metadata=meta_data, 
        #                 scale=0.5, 
        #                 instance_mode=ColorMode.IMAGE_BW   # remove the colors of unsegmented pixels. This option is only available for segmentation models
        # )
        # out = v.draw_instance_predictions(outputs["instances"].to("cpu"))
        # cv2.imshow("img", out.get_image()[:, :, ::-1])
        # cv2.waitKey(0)
        # =================================================================================

        # Subscriber
        self._pcd_sub = None
        self._image_sub = None
        if self._gen_image_from_pcd:
            self._pcd_sub = rospy.Subscriber(self.input_pcd, PointCloud2, self._pcd_callback, queue_size=1)
        else:
            if self._use_compressed_image:
                self._image_sub = rospy.Subscriber(self.input_compressed_image, CompressedImage, self._image_callback, queue_size=1)
            else:
                self._image_sub = rospy.Subscriber(self.input_image, Image, self._image_callback, queue_size=1)

        # Publisher
        self._result_pub = rospy.Publisher(self.output_result_topic, Result, queue_size=1)

        if self._visualization:
            self._vis_pub = rospy.Publisher(self.output_visualization_topic, Image, queue_size=1)

    def generate_image(self, pcd):
        # start_time = time.time()

        # pcd and image size
        if pcd is not None:
            width = pcd.width
            height = pcd.height
            if height == 1:
                resolution = width
                # NFOV Unbinned
                if resolution == 368640:
                    width = 640
                    height = 576
                # NFOV 2x2 Binned (SW)
                elif resolution == 92160:
                    width = 320
                    height = 288
                # WFOV 2x2 Binned
                elif resolution == 262144:
                    width = 512
                    height = 512
                # WFOV Unbinned
                elif resolution == 1048576:
                    width = 1024
                    height = 1024
                else:
                    rospy.logerr("[Detectron2 ROS] Received Unknown Resolution PCD")
                    rospy.logerr("    You can use generating image from pcd only when using Azure Kinect DK.")

            # convert
            array = np.zeros((height, width), dtype=np.float32)

            # save data to arrary
            pcd_original = ros_numpy.numpify(pcd)
            pcd_original = pcd_original.reshape(height, width)
            array[:, :] = pcd_original['rgb']

            # convert color (html color -> rgb)
            data = array.view(np.uint8).reshape(array.shape+(4,))[..., :3]
            image = ros_numpy.msgify(Image, data, encoding='bgr8')
            # finish_time = time.time()
            # print("generate image time : {0}".format(finish_time-start_time))

            return image
        else:
            return None

    def run(self):

        rate = rospy.Rate(self._publish_rate)
        while not rospy.is_shutdown():
            img_msg = None
            # if generate image from pcd indirectly
            if self._gen_image_from_pcd:
                if self._pcd_lock.acquire(False):
                    pcd_msg = self._last_pcd
                    img_msg = self.generate_image(pcd_msg)
                    self._pcd_lock.release()
                else:
                    rate.sleep()
                    continue
            # if subscribe image directly
            else:
                if self._img_lock.acquire(False):
                    img_msg = self._last_img
                    self._img_lock.release()
                else:
                    rate.sleep()
                    continue

            if img_msg is not None:
                # add result of Mask R-CNN
                np_image = self.convert_to_cv_image(img_msg)
                # Only if real, make image smaller
                if self._system_mode == "real" and self._enable_quater_pcd:
                    np_image = np_image[::2, ::2, :]
                outputs = self.predictor(np_image)
                result = outputs["instances"].to("cpu")
                result_msg = self.getResult(result)

                # publish result msg
                self._result_pub.publish(result_msg)
                # Visualize results
                if self._visualization:
                    v = Visualizer(np_image[:, :, ::-1],
                                    metadata=MetadataCatalog.get(self.cfg.DATASETS.TRAIN[0]),
                                    scale=1.2,
                                    instance_mode=ColorMode.SEGMENTATION)
                    # v = Visualizer(np_image[:, :, ::-1], 
                    #                 metadata=self.meta_data, 
                    #                 scale=1.2,
                    #                 instance_mode=ColorMode.SEGMENTATION)
                    v = v.draw_instance_predictions(outputs["instances"].to("cpu"))
                    img = v.get_image()[:, :, ::-1]
                    img = cv.cvtColor(img, cv.COLOR_BGR2RGB)
                    image_msg = self._bridge.cv2_to_imgmsg(img)
                    self._vis_pub.publish(image_msg)

            rate.sleep()

    def getResult(self, predictions):

        boxes = predictions.pred_boxes if predictions.has("pred_boxes") else None

        if predictions.has("pred_masks"):
            masks = np.asarray(predictions.pred_masks)
        else:
            return

        result_msg = Result()
        result_msg.header = self._msg_header
        result_msg.class_ids = predictions.pred_classes if predictions.has("pred_classes") else None
        result_msg.class_names = np.array(self._class_names)[result_msg.class_ids.numpy()]
        result_msg.scores = predictions.scores if predictions.has("scores") else None

        for i, (x1, y1, x2, y2) in enumerate(boxes):
            mask = np.zeros(masks[i].shape, dtype="uint8")
            mask[masks[i, :, :]] = 255
            # mask = self._bridge.cv2_to_imgmsg(mask)
            mask = self._bridge.cv2_to_compressed_imgmsg(mask)
            result_msg.masks.append(mask)

            box = RegionOfInterest()
            box.x_offset = np.uint32(x1)
            box.y_offset = np.uint32(y1)
            box.height = np.uint32(y2 - y1)
            box.width = np.uint32(x2 - x1)
            result_msg.boxes.append(box)

        return result_msg

    def convert_to_cv_image(self, image_msg):

        if image_msg is None:
            return None

        cv_img = None
        # if use compressed image
        if self._use_compressed_image:
            np_arr = np.fromstring(image_msg.data, np.uint8)
            imageBGR = cv.imdecode(np_arr, cv.IMREAD_COLOR)
            imageRGB = cv.cvtColor(imageBGR, cv.COLOR_BGR2RGB)
            cv_img = imageRGB
        # if use normal image
        else:
            self._width = image_msg.width
            self._height = image_msg.height
            channels = int(len(image_msg.data) / (self._width * self._height))

            encoding = None
            if image_msg.encoding.lower() in ['rgb8', 'bgr8', 'bgra8']:
                encoding = np.uint8
            elif image_msg.encoding.lower() == 'mono8':
                encoding = np.uint8
            elif image_msg.encoding.lower() == '32fc1':
                encoding = np.float32
                channels = 1

            cv_img = np.ndarray(shape=(image_msg.height, image_msg.width, channels),
                                dtype=encoding, buffer=image_msg.data)

            if image_msg.encoding.lower() == 'mono8':
                cv_img = cv.cvtColor(cv_img, cv.COLOR_RGB2GRAY)
            else:
                cv_img = cv.cvtColor(cv_img, cv.COLOR_RGB2BGR)

        return cv_img

    def _image_callback(self, msg):
        rospy.loginfo("[detectron2_ros] Get an image")
        if self._img_lock.acquire(False):
            self._last_img = msg
            self._msg_header = msg.header
            self._img_lock.release()

    def _pcd_callback(self, msg):
        rospy.loginfo("[detectron2_ros] Get an PCD")
        if self._pcd_lock.acquire(False):
            self._last_pcd = msg
            self._msg_header = msg.header
            self._pcd_lock.release()


def main(argv):
    rospy.init_node('detectron2_ros')
    cam_index = rospy.get_param("~cam_index")
    node = Detectron2node("{:0=2}".format(cam_index))

    print("===== Mask R-CNN with Detectron2 ======================")
    node.run()


if __name__ == '__main__':
    main(sys.argv)
