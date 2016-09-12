#!/bin/bash

## TODO: Use slave.blend config and start on other hosts in cluster
# for network rendering

BLENDER_VERSION="$1"
GPU_COUNT="$2"

SOFTWARE_RENDER=

# Enable SSH. Not strictly required
sudo service ssh restart

. `dirname $0`/setenv.sh $GPU_COUNT

exec /usr/local/bin/nimbix_desktop /opt/blender/${BLENDER_VERSION}/blender${SOFTWARE_RENDER} -W -noaudio
