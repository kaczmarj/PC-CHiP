#!/bin/bash

set -eux

# Example of use:
# PATH2img=../tcga-images/brca/TCGA-3C-AAAU-01A-01-TS1.2F52DD63-7476-4E85-B7C6-E06092DB6CC1.svs imgID=TCGA-3C-AAAU-01A-01-TS1 bash pipeline.sh

CurDir="$( cd "$(dirname "$0")" ; pwd -P )"
OutputDir="outputdir-jakub"

#### image tiling ####
# tiles will be saved under $OutputDir/tiles with name $imgID_posX_posY.jpg

python $CurDir/preprocess/imgconvert.py $PATH2img $imgID $OutputDir/tiles

#### convert images to tfrecord ####
#file_info_train: //path to tiles//label//code of label//tumor purity(-100 for normal); sep by space
#codebook.txt: //cancer//tissue//code; sep by space

tfrecordDir=$OutputDir/process_test
mkdir -p $tfrecordDir
bash $CurDir/myslim/run/convert.sh $CurDir/file_info_test $tfrecordDir 320

#### compute predictions and bottlenecks ####
PRETRAINED_CHECKPOINT_DIR=$CurDir/myslim/checkpoint
bash $CurDir/myslim/run/bottleneck_predict.sh \
    $PRETRAINED_CHECKPOINT_DIR/model.ckpt-100000 \
    42 \
    $OutputDir/process_test \
    $OutputDir/pred.test.txt \
    $OutputDir/bot.test.txt \
    inception_v4

#### transform bottleneck features // add dummy variable for tissue type for each tile // save predictions in separate files ####
#output: $OutputDir/bot.*.txt.info // $OutputDir/bot.*.txt.pred

bash $CurDir/postprocess/bot.transform.sh $OutputDir/bot.test.txt

#### get prediction within cancer type (instead of among 42 tissues) #####

bash $CurDir/postprocess/get.pred.within.cancer.sh $OutputDir/bot.test.txt.pred
