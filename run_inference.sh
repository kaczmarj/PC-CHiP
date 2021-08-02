#!/usr/bin/env bash

singularity exec --nv --env CUDA_VISIBLE_DEVICES=1 \
	-B /home/jkaczmarzyk/code/PC-CHiP kaczmarj_pc-chip.sif \
	python inception/myslim/bottleneck_predict_jakub.py \
		--bot_out outputs/inference.h5 \
		--checkpoint_path pretrained/Retrained_Inception_v4/model.ckpt-100000 \
		--filedir outputs/tiles/ \
		--model_name inception_v4 \
		--num_classes 42
