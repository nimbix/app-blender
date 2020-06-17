#!/bin/bash

## TODO: Use slave.blend config and start on other hosts in cluster
# for network rendering

SOFTWARE_RENDER=
GPU_COUNT=0
while [ -n "$1" ]; do
  case "$1" in
  -gpus)
    shift
    GPU_COUNT="$1"
    ;;
  *) ;;
  esac
  shift
done

. $(dirname "$0")/setenv.sh "$GPU_COUNT"

# start the GUI with the GPU renderer enabled or the software rendering version
exec /usr/local/bin/nimbix_desktop /opt/blender/blender${SOFTWARE_RENDER} -noaudio
