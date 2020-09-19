import os

ITERRAITON_NUM = [200, 500, 1000, 3000, 5000, 8000, 10000, 20000]
# 1/10, 1/20, 1/50, 1/100
# 2.5e-05, 1.25e-05, 5e-06, 2.5e-06, 1.25e-06
LERNING_RATE = [0.000025, 0.0000125, 0.000005, 0.0000025, 0.00000125]
ORIGINAL_MODEL_NAME = "mask_rcnn_R_101_FPN_3x"

# generate folder
for iteration_num in ITERRAITON_NUM:
    for learning_rate in LERNING_RATE:
        folder_name = (ORIGINAL_MODEL_NAME + "_iter_" + str(iteration_num) + "_learn_" + str(learning_rate)).replace(".", "-")
        os.system("mkdir ./../weights/COCO-InstanceSegmentation/{}".format(folder_name))
os.system("chmod 777 -R ./../weights/COCO-InstanceSegmentation/*  ")

# rename weight files
# for iteration_num in ITERRAITON_NUM:
#     for learning_rate in LERNING_RATE:
#         original_file_name = ORIGINAL_MODEL_NAME + "_iter_" + str(iteration_num) + "_learn_" + str(learning_rate)[2:] + ".pth"
#         new_file_name = (ORIGINAL_MODEL_NAME + "_iter_" + str(iteration_num) + "_learn_" + str(learning_rate)).replace(".", "-") + ".pth"
#         os.system("mv ./../weights/COCO-InstanceSegmentation/{} ./../weights/COCO-InstanceSegmentation/{}".format(original_file_name, new_file_name))