#!/bin/bash

################################
# README
# This .sh file is to:
# 1. Download the client data (if not downloaded)
# 2. Preprocess the client data (downsample + filter the data)
################################


################################
# Setup anaconda3
# https://stackoverflow.com/a/70293309
################################
source ~/anaconda3/bin/activate
conda init bash
echo " "
conda activate mimos


################################
# hyperparameters
################################
ORI_PLY_DIR="data_raw/techpartnerfile/techpartnerfile-ply"
PLY_DIR="data_raw/techpartnerfile/preprocessed_techpartnerfile-ply"
LABEL_DIR="data_raw/techpartnerfile/techpartnerfile_label"

################################
# create directory data_raw to store raw data
################################
if [ -d "data_raw" ]; then
    echo -e "directory data_raw has been created previously.\n"
else
    mkdir -p "data_raw"
    echo -e "Created directory data_raw\n"
fi


################################
# Download client dataset
################################
if [ -d "data_raw/techpartnerfile" ]; then
    echo -e "The client data has been downloaded previously.\n"
else
    cd "data_raw"
    echo -e "The client data zip file does not exists. Downloading now...\n"
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1-p9g4AVO9fxhwYtI-Ab3Se1Mbw7_gW46' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1-p9g4AVO9fxhwYtI-Ab3Se1Mbw7_gW46" -O "techpartnerfile-ply.zip" && rm -rf /tmp/cookies.txt
    unzip "techpartnerfile-ply.zip" -d "techpartnerfile"
    cd ../
    echo " "
fi


################################
# batch preprocessing of data
################################
python3 batch_preprocess.py --input-dir $ORI_PLY_DIR --output-dir $PLY_DIR


################################
# split the data (if necessary)
################################
python3 batch_split.py --ply_dir $PLY_DIR --label_dir $LABEL_DIR


################################
# deactivate conda environment
################################
conda deactivate 