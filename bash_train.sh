#!/bin/bash

################################
# README
# This .sh file is to:
# 1. Convert raw data + labelCloud format -> OpenPCDet raw format for custom data
# 2. Convert OpenPCDet raw format to KITTI
# 3. Train the model
################################


################################
# Setup anaconda3
# https://stackoverflow.com/a/70293309
################################
source ~/anaconda3/bin/activate
conda init bash
echo " "
conda activate openpcdet


################################
# hyperparameters
################################
MODEL='pointpillar'
NAME="custom"
LABEL_DIR="data_raw/techpartnerfile/techpartnerfile_label"
PLY_DIR="data_raw/techpartnerfile/preprocessed_techpartnerfile-ply"

EPOCH=100
BS=4

PC_MF=20           # magnifying factor (MF) to scale up point clouds
DXDY_MF=0.85       # magnifying factor (MF) to scale down dx dy dimension of labels

if [ $MODEL == "pointpillar" ]; then
    CFG_FILE='tools/cfgs/custom_models/pointpillar.yaml'
elif [ $MODEL == "pointrcnn" ]; then
    CFG_FILE='tools/cfgs/custom_models/pointrcnn.yaml'
elif [ $MODEL == "pv_rcnn" ]; then
    CFG_FILE='tools/cfgs/custom_models/pv_rcnn.yaml'
else
    echo "model type not implemented, please check in hyperparameters"
    exit 1
fi


################################
# remove previous models, just in case 
################################
if [ -d output/custom_models/$MODEL ]; then
    echo -e "Directory 'output/custom_models/$MODEL' exist!"
    echo -e "Please rename or delete the directory, because the bash_train.sh is training a new $MODEL."
    exit 1
fi


################################
# Fix the label path name in the json label, in case multiple people did the labelling -> insonsistency in root directory
################################
python3 batch_fix_label.py --ply_dir $PLY_DIR --label_dir $LABEL_DIR || exit 1


################################
# Convert raw data + labelCloud format -> OpenPCDet raw format for custom data 
################################
if [ -d "data/custom" ]; then
    rm -r "data/custom"
fi
python convert_raw_data.py --name $NAME --dir $LABEL_DIR --cfg_file $CFG_FILE --pc_mf $PC_MF --dxdy_mf $DXDY_MF  || exit 1
echo ""

################################
# Convert raw data OpenPCDet raw format for custom data -> some internal format
################################
python -m pcdet.datasets.custom.custom_dataset create_custom_infos tools/cfgs/dataset_configs/custom_dataset.yaml || exit 1


################################
# Train
################################
# pointrcnn
cd tools
python train.py --cfg_file ${CFG_FILE:6:1000} --epochs $EPOCH --batch_size $BS --workers 1 || exit 1

################################
# deactivate conda environment
################################
conda deactivate
