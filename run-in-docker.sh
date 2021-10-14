#!/bin/sh
set -e
docker run --rm -it \
    -v $(pwd):/code/PC-CHiP \
    -v /etc/passwd:/etc/passwd:ro \
    -u $(id -u):$(id -g) \
    -w /code/PC-CHiP \
    --entrypoint bash \
    kaczmarj/pc-chip:20211014 "$@"
