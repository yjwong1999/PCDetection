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
conda activate openpcdet


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
# Download client dataset (which is preprocessed and augmented)
################################
https://drive.google.com/file/d/1Q9Vy_Gd3OLKXVJ9LO0KatQIfu_sPW3Hs/view?usp=sharing
if [ -d "data_raw/techpartnerfile" ]; then
    echo -e "The client data has been downloaded previously.\n"
else
    cd "data_raw"
    echo -e "The client data zip file does not exists. Downloading now...\n"
    # download ply file
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1PEhDVrk0rn1fxMpa_M6TVRzCeG0_x4pT' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1PEhDVrk0rn1fxMpa_M6TVRzCeG0_x4pT" -O "preprocessed_techpartnerfile-ply.zip" && rm -rf /tmp/cookies.txt || exit 1
    unzip "preprocessed_techpartnerfile-ply.zip" -d "techpartnerfile" || exit 1
    # download labels
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=16SNV_o23LslyjRdM1uoqX7vzt1MsrvI3' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=16SNV_o23LslyjRdM1uoqX7vzt1MsrvI3" -O "techpartnerfile_label.zip" && rm -rf /tmp/cookies.txt || exit 1
    unzip "techpartnerfile_label.zip" -d "techpartnerfile" || exit 1
    cd ../
    echo " "
fi

################################
# Fix the label path name in the json label, in case multiple people did the labelling -> insonsistency in root directory
################################
python3 batch_fix_label.py --ply_dir $PLY_DIR --label_dir $LABEL_DIR || exit 1


################################
# deactivate conda environment
################################
conda deactivate 
