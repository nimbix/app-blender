#!/bin/bash

## TODO: Use slave.blend config and start on other hosts in cluster
# for network rendering

SOFTWARE_RENDER=

. $(dirname "$0")/setenv.sh

# start the GUI with the GPU renderer enabled or the software rendering version
exec /usr/local/bin/nimbix_desktop /opt/blender/blender${SOFTWARE_RENDER} -noaudio
