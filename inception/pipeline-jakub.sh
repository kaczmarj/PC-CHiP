#!/usr/bin/env bash

set -eux

# Tile image.
singularity exec -B /home/jkaczmarzyk/code/PC-CHiP/ ../kaczmarj_pc-chip.sif python preprocess/imgconvert.py /home/jkaczmarzyk/data/tcga_images/paad/TCGA-2J-AAB1-01Z-00-DX1.F3B4818F-9C3B-4C66-8241-0570B2873EC9.svs TCGA-2J-AAB1-01Z-00-DX1.F3B4818F-9C3B-4C66-8241-0570B2873EC9.svs ../outputs/tiles


# Run forward pass.
# singularity exec --nv --env CUDA_VISIBLE_DEVICES=0 -B /home/jkaczmarzyk/code/PC-CHiP/ ../kaczmarj_pc-chip.sif python myslim/bottleneck_predict.py --num_classes=42 --bot_out ../outputs/bot-out.txt --model_name=inception_v4 --checkpoint_path=../pretrained/Retrained_Inception_v4/model.ckpt-100000.index --filedir=../outputs/tiles/ --eval_image_size=299
