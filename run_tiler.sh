#!/usr/bin/env bash

singularity exec --bind $(pwd) --bind /data10:/data10:ro kaczmarj_pc-chip.sif \
	bash -c "find /data10/shared/tcga_all/brca/ -maxdepth 1 -type f | xargs -n 1 -P 12 -I {} bash -c 'python inception/preprocess/imgconvert.py {} outputs/tiles/brca'"
