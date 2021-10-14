FROM tensorflow/tensorflow:1.12.0-gpu-py3
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        libice6 \
        libopenslide0 \
        libsm6 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
        opencv-python==4.1.1.26 \
        numpy==1.17.3 \
        openslide-python==1.1.2 \
        pillow

RUN cp /usr/local/cuda/targets/x86_64-linux/lib/stubs/libcuda.so /usr/local/cuda/targets/x86_64-linux/lib/libcuda.so.1
ENV LD_LIBRARY_PATH="/usr/local/cuda/targets/x86_64-linux/lib/:$LD_LIBRARY_PATH"

ENTRYPOINT ["/bin/bash"]
