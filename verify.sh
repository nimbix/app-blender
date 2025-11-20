#!/usr/bin/env bash

IMAGE=$(docker images --format table | grep blender | head -n1 | awk '{print $1 ":" $2}')

if [[ -z $IMAGE ]]; then
    echo "ERROR: Blender image not found."
    exit 1
fi

PORT=${1:-5902}

docker run -it --rm --gpus all --shm-size=16g -v $PWD:/mydata:Z -v $PWD/.data:/data:Z -p $PORT:5902 --entrypoint=bash $IMAGE -ec "
    useradd --shell /bin/bash nimbix
    mkdir -p /home/nimbix/
    mkdir -p /data
    chown -R nimbix:nimbix /home/nimbix
    chown -R nimbix:nimbix /data
    mkdir -p /etc/JARVICE
    cp /mydata/benchmark/benchmark.sh /opt/blender/benchmark/.
    echo 127.0.0.1 > /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 >> /etc/JARVICE/cores
    echo 127.0.0.1 > /etc/JARVICE/nodes
    echo JOB_NAME=Local_Testing >> /etc/JARVICE/jobinfo.sh
    su nimbix -c '
        cd \$HOME
        /opt/blender/benchmark/benchmark.sh -renderFile RyzenGraphic_27 -enableCPU -disableGPU
        echo ""
        echo "=============================================================================="
        echo ""
        /opt/blender/benchmark/benchmark.sh -renderFile RyzenGraphic_27 -gpucount 1
        # ls -lah
        # export XDG_RUNTIME_DIR=\"\$HOME/.xdg_runtime\"
        # mkdir -p \$XDG_RUNTIME_DIR
        # /usr/local/bin/nimbix_desktop /usr/local/scripts/start.sh
    '
"
