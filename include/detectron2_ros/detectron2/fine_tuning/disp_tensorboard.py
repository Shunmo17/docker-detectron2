import os
import sys

ORIGINAL_MODEL_NAME = "mask_rcnn_R_101_FPN_3x"
OUTPUT_DIR = "./../weights/COCO-InstanceSegmentation"
ITERATION_NUM = None
LEARNING_RATE = None
if len(sys.argv) >= 3:
    ITERATION_NUM = sys.argv[1]
    LEARNING_RATE = sys.argv[2]
    folder_name = (ORIGINAL_MODEL_NAME + "_iter_" + str(ITERATION_NUM) + "_learn_" + str(LEARNING_RATE)).replace(".", "-")

    print("========= Display Tensorboard =========")
    print("Iteration Num : {}".format(ITERATION_NUM))
    print("Learning Rate : {}".format(LEARNING_RATE))
    print("folder_name : {}".format(folder_name))
    print("folder dir : {}".format(OUTPUT_DIR + "/" + folder_name))
    print("=======================================")

    os.system("tensorboard --logdir {}".format(OUTPUT_DIR + "/" + folder_name + "/"))
else:
    print("=======================================")
    print("  Usage")
    print("---------------------------------------")
    print("{} iteration_num learning_rate".format(sys.argv[0]))
    print("=======================================")