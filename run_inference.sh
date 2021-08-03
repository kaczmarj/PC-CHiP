#!/usr/bin/env bash

set -e

cancertype="$1"

if [ -z $cancertype ]; then
	echo "usage: $0 CANCERTYPE"
	exit 1
fi

set -eu

root="/home/jkaczmarzyk/code/PC-CHiP/"
filedir="$root/outputs/tiles/$cancertype"

if [ ! -d "$filedir" ]; then
	echo "directory not found: $filedir"
	exit 2
fi

singularity exec \
	--nv \
	--env CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES \
	--bind $root \
	$root/kaczmarj_pc-chip.sif \
	python $root/inception/myslim/bottleneck_predict_jakub.py \
		--bot_out $root/outputs/inference_${cancertype}.h5 \
		--checkpoint_path $root/pretrained/Retrained_Inception_v4/model.ckpt-100000 \
		--filedir $filedir \
		--model_name inception_v4 \
		--num_classes 42
