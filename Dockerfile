FROM tensorflow/tensorflow:1.12.3-gpu-py3
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        libopenslide0 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
        opencv-python==4.1.1.26 \
        numpy==1.17.3 \
        openslide-python==1.1.2

ENTRYPOINT ["python"]
