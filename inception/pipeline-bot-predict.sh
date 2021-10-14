#!/bin/bash

set -eu

# Example of use:
# PATH2img=../tcga-images/brca/TCGA-3C-AAAU-01A-01-TS1.2F52DD63-7476-4E85-B7C6-E06092DB6CC1.svs imgID=TCGA-3C-AAAU-01A-01-TS1 bash pipeline.sh

CurDir="$( cd "$(dirname "$0")" ; pwd -P )"
SLIDE_DIRECTORY=$CurDir/../tcga-images/brca/
OutputDir="outputdir-jakub"

#### image tiling ####
# tiles will be saved under $OutputDir/tiles with name $imgID_posX_posY.jpg
for filename in $SLIDE_DIRECTORY/*.svs; do
    # Skip if filename is empty.
    [ -e "$filename" ] || continue
    imgID="$(basename $filename)"
    # Skip if tiles exist.
    [[ $(ls $OutputDir/tiles/$imgID*.jpg) ]] && continue
    python $CurDir/preprocess/imgconvert.py "$filename" "$imgID" "$OutputDir/tiles"
done

#### convert images to tfrecord ####
#file_info_train: //path to tiles//label//code of label//tumor purity(-100 for normal); sep by space
#codebook.txt: //cancer//tissue//code; sep by space

# Create LIST_OF_JPG_FILES file...
# header:
#   path_2_tile class_name class_id tumor_purity jpeg_quality

LIST_OF_JPG_FILES="$CurDir/file_info_test"
find outputdir-jakub/tiles/ -maxdepth 1 -name '*.jpg' > $LIST_OF_JPG_FILES
# Add columns after the path. But fill these with constants, because we
# don't know what they should be.
sed -i 's/$/ BRCA_T/' $LIST_OF_JPG_FILES
sed -i 's/$/ 3/' $LIST_OF_JPG_FILES
sed -i 's/$/ 90/' $LIST_OF_JPG_FILES
sed -i 's/$/ RGBQ=70/' $LIST_OF_JPG_FILES

# Convert to TFRecord.
tfrecordDir=$OutputDir/process_test
mkdir -p $tfrecordDir
bash $CurDir/myslim/run/convert.sh "$LIST_OF_JPG_FILES" $tfrecordDir 320

#### compute predictions and bottlenecks ####
PRETRAINED_CHECKPOINT_DIR=$CurDir/myslim/checkpoint
bash $CurDir/myslim/run/bottleneck_predict.sh \
    $PRETRAINED_CHECKPOINT_DIR/model.ckpt-100000 \
    42 \
    $tfrecordDir \
    $OutputDir/pred.test.txt \
    $OutputDir/bot.test.txt \
    inception_v4

#### transform bottleneck features // add dummy variable for tissue type for each tile // save predictions in separate files ####
#output: $OutputDir/bot.*.txt.info // $OutputDir/bot.*.txt.pred

bash $CurDir/postprocess/bot.transform.sh $OutputDir/bot.test.txt

#### get prediction within cancer type (instead of among 42 tissues) #####

bash $CurDir/postprocess/get.pred.within.cancer.sh $OutputDir/bot.test.txt.pred
